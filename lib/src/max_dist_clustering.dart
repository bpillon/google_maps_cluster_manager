import '../google_maps_cluster_manager.dart';
import 'common.dart';

class _MinDistCluster<T extends ClusterItem> {
  final Cluster<T> cluster;
  final double dist;

  _MinDistCluster(this.cluster, this.dist);
}

class MaxDistClustering<T extends ClusterItem> {
  ///Complete list of points
  late List<T> dataset;

  List<Cluster<T>> _cluster = [];

  ///Threshold distance for two clusters to be considered as one cluster
  final double epsilon;

  final DistUtils distUtils = DistUtils();

  MaxDistClustering({
    this.epsilon = 1,
  });

  ///Run clustering process, add configs in constructor
  List<Cluster<T>> run(List<T> dataset, int zoomLevel) {
    this.dataset = dataset;

    //initial variables
    List<List<double>> distMatrix = [];
    for (T entry1 in dataset) {
      distMatrix.add([]);
      _cluster.add(Cluster.fromItems([entry1]));
    }
    bool changed = true;
    while (changed) {
      changed = false;
      for (Cluster<T> c in _cluster) {
        _MinDistCluster<T>? minDistCluster = getClosestCluster(c, zoomLevel);
        if (minDistCluster == null || minDistCluster.dist > epsilon) continue;
        _cluster.add(Cluster.fromClusters(minDistCluster.cluster, c));
        _cluster.remove(c);
        _cluster.remove(minDistCluster.cluster);
        changed = true;

        break;
      }
    }
    return _cluster;
  }

  _MinDistCluster<T>? getClosestCluster(Cluster cluster, int zoomLevel) {
    double minDist = 1000000000;
    Cluster<T> minDistCluster = Cluster.fromItems([]);
    for (Cluster<T> c in _cluster) {
      if (c.location == cluster.location) continue;
      double tmp =
          distUtils.getLatLonDist(c.location, cluster.location, zoomLevel);
      if (tmp < minDist) {
        minDist = tmp;
        minDistCluster = Cluster<T>.fromItems(c.items);
      }
    }
    return _MinDistCluster(minDistCluster, minDist);
  }
}
