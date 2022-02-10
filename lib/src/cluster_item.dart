import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

abstract class ClusterItem {
  /// Getter for location
  LatLng get location;
  /// Setter for location.
  set location(LatLng newLocation);

  String? _geohash;
  String get geohash => _geohash ??=
      Geohash.encode(location, codeLength: ClusterManager.precision);

  /// base getId.
  /// If you override it, it uses it's value
  String? getId() { return null; }
}
