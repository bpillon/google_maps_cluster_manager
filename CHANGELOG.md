## 3.1.0

- Bump dependency versions
- Max distance clustering

## 3.0.0+1

- Remove useless log

## 3.0.0

**Breaking changes**:

- `ClusterItem` is now a mixin (or a class to extends from) instead of a wrapper around items. This way you don't have to map your items to ClusterItems before using them.
- Remove now useless `initialZoom` parameter.

## 2.0.0

**Breaking changes**:

- Use mapId (with `setMapId` method) to retrieve the map instead of GoogleMapController. This way, the library depends only on `google_maps_flutter_platform_interface` which makes it compatible both with `google_maps_flutter` and `google_maps_flutter_web`.

## 1.0.0

- Migrate to null safety
- Internalising geohash to make it null safety compatible
- Temporary : remove `google_maps_flutter_web` because it needs a reorganization of the project to work correctly (& it's not null safety compatible for the moment)

## 0.3.0

- Add `google_maps_flutter_web` dependency to be compatible with Flutter web
- Update to `google_maps_flutter` version 1.2.0

## 0.2.1

- Improve potential precision of geohash
- Update to `google_maps_flutter` version 1.0.6

## 0.2.0

- Add `stopClusteringZoom` variable
- Update to `google_maps_flutter` version 1.0.2
- Improve `extraPercent` calculation (thanks to @buntagonalprism)

## 0.1.0

- Fix `getMarkers` signature
- Add gif example

## 0.0.2

- Add `setItems` and `addItem` methods
- Add initial zoom

## 0.0.1

- Initial developers preview release.
