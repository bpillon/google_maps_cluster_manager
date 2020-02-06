import 'dart:math';

import 'package:geohash/geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClusterItem<T> {
  final LatLng location;
  final String geohash;
  final T item;

  ClusterItem(this.location, {this.item})
      : geohash = Geohash.encode(location.latitude, location.longitude);

  String getId() {
    return location.latitude.toString() +
        "_" +
        location.longitude.toString() +
        "_${Random().nextInt(10000)}";
  }
}
