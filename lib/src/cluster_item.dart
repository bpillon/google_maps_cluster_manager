import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class ClusterItem<T> {
  final LatLng location;
  final String geohash;
  final T? item;

  ClusterItem(this.location, {this.item})
      : geohash = Geohash.encode(location.latitude, location.longitude,
            codeLength: ClusterManager.precision);
}
