import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_maps_cluster_manager/flutter_google_maps_cluster_manager.dart';

class DistanceBasedClustering extends ClusterAlgorithm {
  final double thresholdDistance; // en metros

  DistanceBasedClustering({
    required this.thresholdDistance,
  });

  @override
  void cluster(List<ClusterItem> items, Function(Set<Marker>) updateMarkers, Marker Function(Cluster) markerBuilder) {
    List<Cluster> clusters = [];
    Set<ClusterItem> unvisitedItems = items.toSet();

    while (unvisitedItems.isNotEmpty) {
      ClusterItem item = unvisitedItems.first;
      unvisitedItems.remove(item);

      List<ClusterItem> clusterItems = [item];
      for (ClusterItem otherItem in unvisitedItems.toList()) {
        if (_distanceBetween(item.location, otherItem.location) < thresholdDistance) {
          clusterItems.add(otherItem);
          unvisitedItems.remove(otherItem);
        }
      }

      clusters.add(Cluster(clusterItems));
    }

    Set<Marker> markers = clusters.map((cluster) => markerBuilder(cluster)).toSet();
    updateMarkers(markers);
  }

  double _distanceBetween(LatLng start, LatLng end) {
    var earthRadius = 6371000.0; // en metros
    double dLat = _deg2rad(end.latitude - start.latitude);
    double dLng = _deg2rad(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(start.latitude)) * cos(_deg2rad(end.latitude)) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
