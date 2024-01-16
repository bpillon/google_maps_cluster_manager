import 'dart:math';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class DistUtils {
// Zoom-Level:
// Level	# Tiles	Tile width
// (° of longitudes)	m / pixel
// (on Equator)	~ Scale
// (on screen)	Examples of
// areas to represent
// 0	1	360	156 412	1:500 million	whole world
// 1	4	180	78 206	1:250 million
// 2	16	90	39 103	1:150 million	subcontinental area
// 3	64	45	19 551	1:70 million	largest country
// 4	256	22.5	9 776	1:35 million
// 5	1 024	11.25	4 888	1:15 million	large African country
// 6	4 096	5.625	2 444	1:10 million	large European country
// 7	16 384	2.813	1 222	1:4 million	small country, US state
// 8	65 536	1.406	610.984	1:2 million
// 9	262 144	0.703	305.492	1:1 million	wide area, large metropolitan area
// 10	1 048 576	0.352	152.746	1:500 thousand	metropolitan area
// 11	4 194 304	0.176	76.373	1:250 thousand	city
// 12	16 777 216	0.088	38.187	1:150 thousand	town, or city district
// 13	67 108 864	0.044	19.093	1:70 thousand	village, or suburb
// 14	268 435 456	0.022	9.547	1:35 thousand
// 15	1 073 741 824	0.011	4.773	1:15 thousand	small road
// 16	4 294 967 296	0.005	2.387	1:8 thousand	street
// 17	17 179 869 184	0.003	1.193	1:4 thousand	block, park, addresses
// 18	68 719 476 736	0.001	0.596	1:2 thousand	some buildings, trees
// 19	274 877 906 944	0.0005	0.298	1:1 thousand	local highway and crossing details
// 20	1 099 511 627 776	0.00025	0.149	1:5 hundred	A mid-sized building
  final Map<(LatLng, LatLng), double> distCache = {};

  double getLatLonDist(LatLng point1, LatLng point2, int zoomLevel) {
    if (distCache[(point1, point2)] != null) {
      return distCache[(point1, point2)]!;
    }
    double meterPerPixel = _getScalingFactor(zoomLevel);
    double dist = getDistanceFromLatLonInKm(point1.latitude, point1.longitude,
            point2.latitude, point2.longitude) /
        (meterPerPixel / 1000);
    // print("dist is $x");
    distCache[(point1, point2)] = dist;
    return dist;
  }

  double getDistanceFromLatLonInKm(
      double lat1, double lon1, double lat2, double lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = _degreeToRadian(lat2 - lat1);
    var dLon = _degreeToRadian(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) *
            cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  double _getScalingFactor(int zoomLevel) {
    switch (zoomLevel) {
      case 0:
        return 156412;
      case 1:
        return 78206;
      case 2:
        return 39103;
      case 3:
        return 19551;
      case 4:
        return 9776;
      case 5:
        return 4888;
      case 6:
        return 2444;
      case 7:
        return 1222;
      case 8:
        return 610.984;
      case 9:
        return 305.492;
      case 10:
        return 152.746;
      case 11:
        return 76.373;
      case 12:
        return 38.187;
      case 13:
        return 19.093;
      case 14:
        return 9.547;
      case 15:
        return 4.773;
      case 16:
        return 2.387;
      case 17:
        return 1.193;
      case 18:
        return 0.596;
      case 19:
        return 0.298;
      case 20:
        return 0.149;
      default:
        return 0.149;
    }
  }
}
