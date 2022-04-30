import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lomi/models/driver.dart';
import 'package:lomi/models/rider.dart';
import 'package:lomi/models/user.dart';

class Database {
// Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final ridersRef = FirebaseFirestore.instance.collection('riders');
  final driversRef = FirebaseFirestore.instance.collection('drivers');

  Future updateMyLocation(User user) async {
    if (user is Rider) {
      return ridersRef.doc(user.id).set(user.toMap());
    } else {
      user as Driver;
      return driversRef.doc(user.id).set(user.toMap());
    }
  }

  Stream<Rider> getRiderLocation(Rider rider) {
    return ridersRef
        .doc(rider.id)
        .snapshots()
        .map((riderData) => Rider.fromMap(riderData.data()!));
  }

  Stream<List<Driver>> getNearbyDrivers(LatLng riderPos) {
    GeoFirePoint center =
        geo.point(latitude: riderPos.latitude, longitude: riderPos.longitude);
    return geo
        .collection(collectionRef: driversRef)
        .within(center: center, radius: 50, field: 'position')
        .map((snapshot) =>
            snapshot.map((snap) => Driver.fromMap(snap.data()!)).toList());
  }

  addDummyDriver() {
    final fakeLocation =
        geo.point(latitude: 6.4876879, longitude: 3.8539647).data;
    driversRef
        .doc()
        .set(Driver(id: '2', name: 'sh', position: fakeLocation).toMap());
  }
}
