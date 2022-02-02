import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_cluster_manager/src/common.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  group("test get_distance of coordinates", () {
    test(
        "should get dist of between 600m and 800m on call with close coordinates",
        () {
      LatLng start = LatLng(52.421327, 10.623056);
      LatLng end = LatLng(52.42748887594039, 10.623379056822062);
      final DistUtils utils = DistUtils();
      double dist = utils.getDistanceFromLatLonInKm(
          start.latitude, start.longitude, end.latitude, end.longitude);
      print("dist is $dist");
      expect(dist >= 0.6 && dist <= 0.8, true);
    });

    test(
        "should get dist of between 75km and 80km on call with wider coordinates",
        () {
      LatLng start = LatLng(52.45175365359977, 10.679139941065786);
      LatLng end = LatLng(51.7578902763405, 10.74257578002594);
      final DistUtils utils = DistUtils();
      double dist = utils.getDistanceFromLatLonInKm(
          start.latitude, start.longitude, end.latitude, end.longitude);
      print("dist is $dist");
      expect(dist >= 75 && dist <= 80, true);
    });

    test("should map distance of 77km with zoomLevel to ", () {
      LatLng start = LatLng(52.45175365359977, 10.679139941065786);
      LatLng end = LatLng(51.7578902763405, 10.74257578002594);
      final DistUtils utils = DistUtils();

      double dist = utils.getLatLonDist(start, end, 16);
      print("dist is $dist ${75 / 2.387 * 1000} ${80 / 2.387 * 1000}");
      expect(dist >= 75 / 2.387 * 1000 && dist <= 80 / 2.387 * 1000, true);
    });
  });
}
