#import "RNAdMobEvent.h"
#import "RNAdMobCommon.h"

@interface RNAdMobRewarded : NSObject <RCTBridgeModule, GADFullScreenContentDelegate>
@end

static __strong NSMutableDictionary *requestIdMap;
static __strong NSMutableDictionary *adMap;
static __strong NSMutableDictionary *presentAdResolveMap;
static __strong NSMutableDictionary *presentAdRejectMap;

@implementation RNAdMobRewarded

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL) requiresMainQueueSetup
{
    return true;
}

- (id)init {
    self = [super init];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestIdMap = [[NSMutableDictionary alloc] init];
        adMap = [[NSMutableDictionary alloc] init];
        presentAdResolveMap = [[NSMutableDictionary alloc] init];
        presentAdRejectMap = [[NSMutableDictionary alloc] init];
    });
    return self;
}


- (void)dealloc {
    [self invalidate];
}

- (void)invalidate {
    [requestIdMap removeAllObjects];
    [adMap removeAllObjects];
    [presentAdResolveMap removeAllObjects];
    [presentAdRejectMap removeAllObjects];
}

RCT_EXPORT_MODULE();

#pragma mark exported methods

RCT_EXPORT_METHOD(requestAd:(NSNumber *_Nonnull)requestId
                  unitId:(NSString *_Nonnull)unitId
                  requestOptions:(NSDictionary *)requestOptions
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    GAMRequest *request = [RNAdMobCommon buildAdRequest:requestOptions];
    [GADRewardedAd loadWithAdUnitID:unitId
                            request:request
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            reject(@"E_AD_LOAD_FAILED", [error localizedDescription], error);
            return;
        }
        
        ad.fullScreenContentDelegate = self;
        
        requestIdMap[ad.responseInfo.responseIdentifier] = requestId;
        adMap[requestId] = ad;
        
        resolve(nil);
    }];
}

RCT_EXPORT_METHOD(presentAd:(NSNumber *_Nonnull)requestId resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    GADRewardedAd *ad = adMap[requestId];
    presentAdResolveMap[requestId] = resolve;
    presentAdRejectMap[requestId] = reject;
    if (ad) {        
        [ad presentFromRootViewController:RCTPresentedViewController()
                 userDidEarnRewardHandler:^ {
            GADAdReward *reward = ad.adReward;
            [self sendEvent:kEventRewarded requestId:requestId data:@{@"type": reward.type, @"amount": reward.amount}];
        }];
    }
    else {
        reject(@"E_AD_NOT_READY", @"Ad is not ready.", nil);
    }
}

- (void)sendEvent:(NSString *)eventName requestId:(NSNumber *)requestId data:(NSDictionary *)data
{
    [RNAdMobEvent sendEvent:eventName type:@"Rewarded" requestId:requestId data:data];
}

#pragma mark GADFullScreenContentDelegate

- (void)adDidPresentFullScreenContent:(GADRewardedAd *)ad
{
    NSNumber *requestId = requestIdMap[ad.responseInfo.responseIdentifier];
    
    [self sendEvent:kEventAdPresented requestId:requestId data:nil];
    
    RCTPromiseResolveBlock resolve = presentAdResolveMap[requestId];
    resolve(nil);
}

- (void)ad:(GADRewardedAd *)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    NSNumber *requestId = requestIdMap[ad.responseInfo.responseIdentifier];
    
    NSDictionary *jsError = RCTJSErrorFromCodeMessageAndNSError(@"E_AD_PRESENT_FAILED", error.localizedDescription, error);
    [self sendEvent:kEventAdFailedToPresent requestId:requestId data:jsError];
    
    RCTPromiseRejectBlock reject = presentAdRejectMap[requestId];
    reject(@"E_AD_PRESENT_FAILED", [error localizedDescription], error);
}

- (void)adDidDismissFullScreenContent:(GADRewardedAd *)ad
{
    NSNumber *requestId = requestIdMap[ad.responseInfo.responseIdentifier];
    
    [self sendEvent:kEventAdDismissed requestId:requestId data:nil];
}

@end
