import 'dart:convert';

import 'package:lomi/models/user.dart';

class Rider extends User {
  Rider({required String id, required String name, required position})
      : super(id: id, name: name, position: position);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
    };
  }

  factory Rider.fromMap(Map<String, dynamic> data) =>
      Rider(id: data['id'], name: data['name'], position: data['position']);

  String toJson() => json.encode(toMap());
}
