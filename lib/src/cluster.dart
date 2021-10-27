import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class Cluster<T extends ClusterItem> {
  final LatLng location;
  final Iterable<T> items;

  Cluster(this.items, this.location);

  Cluster.fromItems(Iterable<T> items)
      : this.items = items,
        this.location = LatLng(
            items.fold<double>(0.0, (p, c) => p + c.location.latitude) /
                items.length,
            items.fold<double>(0.0, (p, c) => p + c.location.longitude) /
                items.length);

  //location becomes weighted avarage lat lon
  Cluster.fromClusters(Cluster<T> cluster1, Cluster<T> cluster2)
      : this.items = cluster1.items.toSet()..addAll(cluster2.items.toSet()),
        this.location = LatLng(
            (cluster1.location.latitude * cluster1.count +
                    cluster2.location.latitude * cluster2.count) /
                (cluster1.count + cluster2.count),
            (cluster1.location.longitude * cluster1.count +
                    cluster2.location.longitude * cluster2.count) /
                (cluster1.count + cluster2.count));

  /// Get number of clustered items
  int get count => items.length;

  /// True if cluster is not a single item cluster
  bool get isMultiple => items.length > 1;

  /// Basic cluster marker id
  String getId() {
    return location.latitude.toString() +
        "_" +
        location.longitude.toString() +
        "_$count";
  }

  @override
  String toString() {
    return 'Cluster of $count $T (${location.latitude}, ${location.longitude})';
  }

  bool operator ==(o) => o is Cluster && items == o.items;
  int get hashCode => items.hashCode;
}
