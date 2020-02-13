import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_cluster_manager/src/cluster_item.dart';
import 'package:google_maps_cluster_manager/src/utils/extensions.dart';
import 'package:google_maps_cluster_manager/src/utils/boudaries.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClusterManager<T> {
  ClusterManager(this._items, this.updateMarkers,
      {Future<Marker> Function(Cluster<T>) markerBuilder,
      this.levels = const [1, 3.5, 5, 8.25, 11.5, 14.5, 16, 16.5, 20],
      this.extraPercent = 0.2,
      this.initialZoom = 5.0})
      : this.markerBuilder = markerBuilder ?? _basicMarkerBuilder;

  // Method to build markers
  final Future<Marker> Function(Cluster<T>) markerBuilder;

  // Function to update Markers on Google Map
  final void Function(Set<Marker>) updateMarkers;

  // Zoom levels configuration
  final List<double> levels;

  // Extra percent of markers to be loaded (ex : 0.2 for 20%)
  final double extraPercent;

  final double initialZoom;

  // Google Maps constroller
  GoogleMapController _mapController;

  // List of items
  Iterable<ClusterItem<T>> get items => _items;
  Iterable<ClusterItem<T>> _items;

  // Last known zoom
  double get _currentZoom => _zoom ?? initialZoom;
  double _zoom;

  void setMapController(GoogleMapController controller,
      {bool withUpdate = true}) {
    _mapController = controller;
    if (withUpdate) updateMap();
  }

  void updateMap() {
    updateClusters();
  }

  void setItems(List<ClusterItem<T>> newItems) {
    _items = newItems;
    updateMap();
  }

  void addItem(ClusterItem<T> newItem) {
    _items = List.from([...items, newItem]);
    updateMap();
  }

  void onCameraMove(CameraPosition position, {forceUpdate = false}) {
    _zoom = position.zoom;
    if (forceUpdate) {
      updateMap();
    }
  }

  void updateClusters() async {
    List<Cluster<T>> mapMarkers = await getMarkers();

    final Set<Marker> markers =
        Set.from(await Future.wait(mapMarkers.map((m) => markerBuilder(m))));

    updateMarkers(markers);
  }

  Future<List<Cluster<T>>> getMarkers() async {
    if (_mapController == null) return List();

    LatLngBounds latLngBounds = await _mapController.getVisibleRegion();

    Boundaries latitudeBoundaries = Boundaries(
        latLngBounds.northeast.latitude, latLngBounds.southwest.latitude);
    Boundaries longitudeBoundaries = Boundaries(
        latLngBounds.northeast.longitude, latLngBounds.southwest.longitude);

    List<ClusterItem<T>> visibleItems = items.where((i) {
      bool latQuery = i.location.latitude >=
              latitudeBoundaries.min.removePercentage(extraPercent) &&
          i.location.latitude <=
              latitudeBoundaries.max.addPercentage(extraPercent);

      bool longQuery = i.location.longitude >=
              longitudeBoundaries.min.removePercentage(extraPercent) &&
          i.location.longitude <=
              longitudeBoundaries.max.addPercentage(extraPercent);

      return latQuery && longQuery;
    }).toList();

    int level = _findLevel(levels);

    List<Cluster<T>> markers = List();
    markers = _computeClusters(visibleItems, List(), level: level);

    return markers;
  }

  int _findLevel(List<double> levels) {
    for (int i = levels.length - 1; i >= 0; i--) {
      if (levels[i] <= _currentZoom) return i + 1;
    }

    return 1;
  }

  List<Cluster<T>> _computeClusters(
      List<ClusterItem<T>> inputItems, List<Cluster<T>> markerItems,
      {int level = 5}) {
    if (inputItems.isEmpty) return markerItems;

    String nextGeohash = inputItems[0].geohash.substring(0, level);

    List<ClusterItem<T>> items = inputItems
        .where((p) => p.geohash.substring(0, level) == nextGeohash)
        .toList();

    markerItems.add(Cluster<T>(items));

    List<ClusterItem<T>> newInputList = List.from(
        inputItems.where((i) => i.geohash.substring(0, level) != nextGeohash));

    return _computeClusters(newInputList, markerItems, level: level);
  }

  static Future<Marker> Function(Cluster) get _basicMarkerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            print(cluster);
          },
          icon: await _getBasicClusterBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  static Future<BitmapDescriptor> _getBasicClusterBitmap(int size,
      {String text}) async {
    assert(size != null);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.red;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }
}
