// Null-safety version of llamadonica library (https://github.com/llamadonica/dart-geohash)

// Copyright (c) 2015-2018, llamadonica. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// A collection of static functions to work with geohashes, as exlpained
/// [here](https://en.wikipedia.org/wiki/Geohash)
class Geohash {
  static const Map<String, int> _base32CharToNumber = const <String, int>{
    '0': 0,
    '1': 1,
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    'b': 10,
    'c': 11,
    'd': 12,
    'e': 13,
    'f': 14,
    'g': 15,
    'h': 16,
    'j': 17,
    'k': 18,
    'm': 19,
    'n': 20,
    'p': 21,
    'q': 22,
    'r': 23,
    's': 24,
    't': 25,
    'u': 26,
    'v': 27,
    'w': 28,
    'x': 29,
    'y': 30,
    'z': 31
  };
  static const List<String> _base32NumberToChar = const <String>[
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'j',
    'k',
    'm',
    'n',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z'
  ];

  /// Encode a latitude and longitude pair into a  geohash string.
  static String encode(final LatLng latLng, {final int codeLength = 12}) {
    if (codeLength > 20 || (identical(1.0, 1) && codeLength > 12)) {
      //Javascript can only handle 32 bit ints reliably.
      throw ArgumentError(
          'latitude and longitude are not precise enough to encode $codeLength characters');
    }
    final latitudeBase2 = (latLng.latitude + 90) * (pow(2.0, 52) / 180);
    final longitudeBase2 = (latLng.longitude + 180) * (pow(2.0, 52) / 360);
    final longitudeBits = (codeLength ~/ 2) * 5 + (codeLength % 2) * 3;
    final latitudeBits = codeLength * 5 - longitudeBits;
    var longitudeCode = (identical(1.0, 1)) //Test for javascript.
        ? (longitudeBase2 / (pow(2.0, 52 - longitudeBits))).floor()
        : longitudeBase2.floor() >> (52 - longitudeBits);
    var latitudeCode = (identical(1.0, 1)) //Test for javascript.
        ? (latitudeBase2 / (pow(2.0, 52 - latitudeBits))).floor()
        : latitudeBase2.floor() >> (52 - latitudeBits);

    final stringBuffer = [];
    for (var localCodeLength = codeLength;
        localCodeLength > 0;
        localCodeLength--) {
      int bigEndCode, littleEndCode;
      if (localCodeLength % 2 == 0) {
        //Even slot. Latitude is more significant.
        bigEndCode = latitudeCode;
        littleEndCode = longitudeCode;
        latitudeCode >>= 3;
        longitudeCode >>= 2;
      } else {
        bigEndCode = longitudeCode;
        littleEndCode = latitudeCode;
        latitudeCode >>= 2;
        longitudeCode >>= 3;
      }
      final code = ((bigEndCode & 4) << 2) |
          ((bigEndCode & 2) << 1) |
          (bigEndCode & 1) |
          ((littleEndCode & 2) << 2) |
          ((littleEndCode & 1) << 1);
      stringBuffer.add(_base32NumberToChar[code]);
    }
    final buffer = StringBuffer()..writeAll(stringBuffer.reversed);
    return buffer.toString();
  }

  /// Get the rectangle that covers the entire area of a geohash string.
  static Rectangle<double> getExtents(String geohash) {
    final codeLength = geohash.length;
    if (codeLength > 20 || (identical(1.0, 1) && codeLength > 12)) {
      //Javascript can only handle 32 bit ints reliably.
      throw ArgumentError(
          'latitude and longitude are not precise enough to encode $codeLength characters');
    }
    var latitudeInt = 0;
    var longitudeInt = 0;
    var longitudeFirst = true;
    for (var character
        in geohash.codeUnits.map((r) => String.fromCharCode(r))) {
      int? thisSequence;
      try {
        thisSequence = _base32CharToNumber[character];
      } on Exception catch (_) {
        throw ArgumentError('$geohash was not a geohash string');
      }
      final bigBits = ((thisSequence! & 16) >> 2) |
          ((thisSequence & 4) >> 1) |
          (thisSequence & 1);
      final smallBits = ((thisSequence & 8) >> 2) | ((thisSequence & 2) >> 1);
      if (longitudeFirst) {
        longitudeInt = (longitudeInt << 3) | bigBits;
        latitudeInt = (latitudeInt << 2) | smallBits;
      } else {
        longitudeInt = (longitudeInt << 2) | smallBits;
        latitudeInt = (latitudeInt << 3) | bigBits;
      }
      longitudeFirst = !longitudeFirst;
    }
    final longitudeBits = (codeLength ~/ 2) * 5 + (codeLength % 2) * 3;
    final latitudeBits = codeLength * 5 - longitudeBits;
    if (identical(1.0, 1)) {
      // Some of our intermediate numbers are STILL too big for javascript,
      // so  we use floating point math...
      final longitudeDiff = pow(2.0, 52 - longitudeBits);
      final latitudeDiff = pow(2.0, 52 - latitudeBits);
      final latitudeFloat = latitudeInt.toDouble() * latitudeDiff;
      final longitudeFloat = longitudeInt.toDouble() * longitudeDiff;
      final latitude = latitudeFloat * (180 / pow(2.0, 52)) - 90;
      final longitude = longitudeFloat * (360 / pow(2.0, 52)) - 180;
      final num height = latitudeDiff * (180 / pow(2.0, 52));
      final num width = longitudeDiff * (360 / pow(2.0, 52));
      return Rectangle<double>(
          latitude, longitude, height.toDouble(), width.toDouble());
    }

    longitudeInt = longitudeInt << (52 - longitudeBits);
    latitudeInt = latitudeInt << (52 - latitudeBits);
    final longitudeDiff = 1 << (52 - longitudeBits);
    final latitudeDiff = 1 << (52 - latitudeBits);
    final latitude = latitudeInt.toDouble() * (180 / pow(2.0, 52)) - 90;
    final longitude = longitudeInt.toDouble() * (360 / pow(2.0, 52)) - 180;
    final height = latitudeDiff.toDouble() * (180 / pow(2.0, 52));
    final width = longitudeDiff.toDouble() * (360 / pow(2.0, 52));
    return Rectangle<double>(latitude, longitude, height, width);
  }

  /// Get a single number that is the center of a specific geohash rectangle.
  static LatLng decode(String geohash) {
    final extents = getExtents(geohash);
    final x = extents.left + extents.width / 2;
    final y = extents.top + extents.height / 2;
    return LatLng(x, y);
  }
}
