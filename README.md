# Flutter Clustering for Google Maps

A Flutter package to cluster items on a [Google Maps](https://pub.dev/packages/google_maps_flutter) widget. Highly inspired by [clustering_google_maps](https://pub.dev/packages/clustering_google_maps)

## Usage

To use this package, add `google_maps_cluster_manager` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Getting Started

Your map items has to be `ClusterItem<T>`. This is basically a wrapper around `LatLng` which is able to carry an object of `T` type (not mandatory). This way, when you click on a cluster, you are able to retrieve `T` objects that are gathered by the cluster.

To start with Cluster Manager, you have to initialize a `ClusterManager` instance.

```dart
ClusterManager<Place>(items, // Your items to be clustered on the map (of Place type for this example)
    _updateMarkers, // Method to be called when markers are updated
    markerBuilder: _markerBuilder, // Optional : Method to implement if you want to customise markers
    levels: [1, 3.5, 5.5, 8.25, 11.5, 14.5, 16, 16.5, 20]
    ), // Optional : Configure this if you want to change zoom levels at which the clustering precision change
    extraPercent: 0.2 // Optional : This number represents the percentage (0.2 for 20%) of latitude and longitude (in each direction) to be considered on top of the visible map bounds to render clusters. This way, clusters don't "pop out" when you cross the map.
);
```

You can customise the icon of a cluster by using `Future<Marker> Function(Cluster<T>) markerBuilder` parameter.

```dart
static Future<Marker> Function(Cluster) get markerBuilder =>
    (cluster) async {
    return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        onTap: () {
            print(cluster);
        },
        icon: await getClusterBitmap(cluster.isMultiple ? 125 : 75,
        text: cluster.isMultiple? cluster.count.toString() : null),
    );
};

static Future<BitmapDescriptor> getClusterBitmap(int size,
    {String text}) async {
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
```

Every cluster (even 1 item clusters) is rendered by the library as a `Cluster<T>` object. You can differentiate single item clusters from multiple ones by using the `isMultiple` variable (or the `count` variable). This way, you can create different markers icon depending on the type of cluster.

## Complete Basic Example

```dart
class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  ClusterManager _manager;

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers = Set();

  final CameraPosition _parisCameraPosition =
      CameraPosition(target: LatLng(48.856613, 2.352222), zoom: 12.0);

  List<ClusterItem<Place>> items = [
    for (int i = 0; i < 10; i++)
      ClusterItem(LatLng(48.848200 + i * 0.001, 2.319124 + i * 0.001),
          item: Place(name: 'Place $i')),
    for (int i = 0; i < 10; i++)
      ClusterItem(LatLng(48.858265 - i * 0.001, 2.350107 + i * 0.001),
          item: Place(name: 'Restaurant $i')),
    for (int i = 0; i < 10; i++)
      ClusterItem(LatLng(48.858265 + i * 0.01, 2.350107 - i * 0.01),
          item: Place(name: 'Bar $i')),
    for (int i = 0; i < 10; i++)
      ClusterItem(LatLng(48.858265 - i * 0.1, 2.350107 - i * 0.01),
          item: Place(name: 'Hotel $i')),
    for (int i = 0; i < 10; i++)
      ClusterItem(LatLng(48.858265 + i * 0.1, 2.350107 + i * 0.1)),
    for (int i = 0; i < 10; i++)
      ClusterItem(LatLng(48.858265 + i * 1, 2.350107 + i * 1)),
  ];

  @override
  void initState() {
    _manager = _initClusterManager();
    super.initState();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Update markers ${markers.length}');
    setState(() {
      this.markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _parisCameraPosition,
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _manager.setMapController(controller);
        },
        onCameraMove: _manager.onCameraMove,
        onCameraIdle: _manager.updateMap,
      ),
    );
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            cluster.items.forEach((s) => print('Place : ${s.name}'));

            print('---- ${cluster.toString()}');
          },
          icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String text}) async {
    assert(size != null);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.red;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

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
```

See the `example` directory for a complete sample app.
