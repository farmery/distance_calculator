import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Position {
  String geohash;
  GeoPoint geopoint;
  Position({
    required this.geohash,
    required this.geopoint,
  });

  Map<String, dynamic> toMap() {
    return {
      'geopoint': GeoPoint(geopoint.latitude, geopoint.longitude),
      'geohash': geohash,
    };
  }

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      geohash: map['geohash'],
      geopoint:
          GeoPoint(map['geopoint']['latitude'], map['geopoint']['longitude']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Position.fromJson(String source) =>
      Position.fromMap(json.decode(source));

  @override
  String toString() => 'Position(geopoint: $geopoint)';
}
