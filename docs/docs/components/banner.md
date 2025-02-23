---
id: banner
title: BannerAd
sidebar_label: BannerAd
---

Renders a [Banner Ad](https://support.google.com/admob/answer/9993556). Supports both AdMob and AdManager.

```jsx
import { BannerAd } from '@react-native-admob/admob';

export default function App() {
  const bannerRef = useRef(null);
  return (
    <View>
      <BannerAd
        size={BannerAdSize.BANNER}
        unitId={UNIT_ID_BANNER}
        onAdFailedToLoad={(error) => console.error(error)}
        ref={bannerRef}
      />
      <Button title="Reload" onPress={() => bannerRef.current?.loadAd()} />
    </View>
  );
}
```

## Props

### `unitId`

Your Banner Ad's [ad Unit ID](https://support.google.com/admob/answer/7356431)

| Type   |
| :----- |
| string |

### `size`

The size of the banner. Can be a predefined size via `BannerAdSize` or custom dimensions, e.g. `300x200`.

| Type                                    |
| :-------------------------------------- |
| [BannerAdSize](#banneradsize) \| string |

### `sizes`

The available sizes of the banner. Can be a predefined sizes via `BannerAdSize` or custom dimensions, e.g. `300x200`. Available only in Ad Manager ad.

| Type                                        |
| :------------------------------------------ |
| [BannerAdSize](#banneradsize)[] \| string[] |

### `requestOptions`

Optional RequestOptions used to load the ad. 

| Type                                       |
| :----------------------------------------- |
| [RequestOptions](/docs/api/RequestOptions) |

### `onSizeChange`

A callback that gets called when an ad's size has changed.

| Type                 |
| :------------------- |
| (size: Size) => void |

### `onAdLoaded`

A callback that gets called when an ad has finished loading.

| Type       |
| :--------- |
| () => void |

### `onAdFailedToLoad`

A callback that gets called when an ad has failed to load. Callback contains an Error.

| Type       |
| :--------- |
| () => void |

### `onAdOpened`

A callback that gets called when the user tapped the ad and the ad content is now visible to the user.

| Type       |
| :--------- |
| () => void |

### `onAdClosed`

A callback that gets called when the user is about to return to the app after tapping on an ad.

| Type       |
| :--------- |
| () => void |

### `onAppEvent`

A callback that gets called when the Ad Manager specific app events occured. Availbale only in Ad Manager Ad.

| Type                                 |
| :----------------------------------- |
| (name: string, info: string) => void |

## Methods

### `loadAd()`

```js
bannerAdRef.cuurent?.loadAd();
```

Load new ad into the view.

## Type Definitions

### BannerAdSize

| Type   |
| :----- |
| string |

Avaliable values:

| Name             | Description                       |
| :--------------- | :-------------------------------- |
| BANNER           | 320x50 size Banner                |
| LARGE_BANNER     | 320x100 size Large Banner         |
| MEDIUM_RECTANGLE | 300x250 size IAB Medium Rectangle |
| FULL_BANNER      | 468x60 size IAB Full-Size Banner  |
| LEADERBOARD      | 728x90 size IAB Leaderboard       |
| ADAPTIVE_BANNER  | Adaptive height Adaptive Banner   |

### Size

| Type   |
| :----- |
| object |

Properties:

| Name   | Type   |
| :----- | :----- |
| width  | number |
| height | number |