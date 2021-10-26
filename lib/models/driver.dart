import 'dart:convert';
import 'user.dart';

class Driver extends User {
  Driver({required String name, required String id, required position})
      : super(id: id, name: name, position: position);

  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id, 'position': position};
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      position: map['position'],
      id: map['id'],
      name: map['name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Driver.fromJson(String source) => Driver.fromMap(json.decode(source));

  @override
  String toString() => 'Driver(name: $name)';
}
