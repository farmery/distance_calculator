import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lomi/data/database.dart';
import 'package:lomi/data/places_api.dart';
import 'package:lomi/models/rider.dart';
import 'package:lomi/screens/home/components/search_bar.dart';
import 'package:lomi/screens/home/components/search_delegate.dart';
import 'package:lomi/screens/sign_in/sign_in_controller.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> completer = Completer();
  Position? myLocation;
  final geo = Geoflutterfire();
  final Database database = Database();
  Map<MarkerId, Marker> markers = {};
  Map<CircleId, Circle> searchRadius = {};
  Map<PolylineId, Polyline> polyLines = {};
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late String userName;
  late TextEditingController textEditingController;
  late BitmapDescriptor icon;
  PlaceApiProvider api = PlaceApiProvider(DateTime.now().toIso8601String());

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    userName = Provider.of<SignInController>(context, listen: false).userName!;
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), 'assets/icons/driver.png')
        .then((value) => icon = value);
    initPosition();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    completer.future.then((value) => value.dispose());
  }

  @override
  Widget build(BuildContext context) {
    getNearbyDrivers();
    updateMyLocation();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(
          children: [
            myLocation != null
                ? GoogleMap(
                    circles: Set.of(searchRadius.values),
                    polylines: Set.of(polyLines.values),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target:
                          LatLng(myLocation!.latitude, myLocation!.longitude),
                      zoom: 13.2,
                    ),
                    onMapCreated: (controller) {
                      completer.complete(controller);
                    },
                    markers: Set<Marker>.of(markers.values),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'menu',
                    mini: true,
                    child: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  heroTag: 'my location',
                  mini: true,
                  child: const Icon(Icons.my_location_rounded),
                  onPressed: () {
                    animateToMyLocation();
                  },
                ),
              ),
            ),
            Positioned(
              top: 49,
              child: GestureDetector(
                onTap: () async {
                  double lat;
                  double lng;
                  if (myLocation != null) {
                    lat = myLocation!.latitude;
                    lng = myLocation!.longitude;
                  } else {
                    Position myLocation = await Geolocator.getCurrentPosition();
                    lat = myLocation.latitude;
                    lng = myLocation.longitude;
                  }
                  final LatLng? locationSearchResult = await showSearch<LatLng>(
                      context: context, delegate: MySearchDelegate());
                  if (locationSearchResult != null) {
                    final polylineCoordinates = await api.drawRoute(
                        locationSearchResult, LatLng(lat, lng));
                    addPolyline(polylineCoordinates);
                    final markerId = MarkerId(locationSearchResult.toString());
                    final destMarker = Marker(
                        markerId: markerId, position: locationSearchResult);
                    markers[markerId] = destMarker;
                    calculateDistance(locationSearchResult).then((distance) {
                      completer.future.then((controller) =>
                          controller.animateCamera(CameraUpdate.newLatLngZoom(
                            locationSearchResult,
                            11.5,
                          )));
                      Future.delayed(const Duration(milliseconds: 250))
                          .then((value) {
                        return showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return Container(
                              color: Colors.white,
                              height: 60,
                              child: Text(
                                  '$distance meters journey to your destination'),
                            );
                          },
                        );
                      });
                    });
                  }
                },
                child: const SearchBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateMyLocation() {
    Geolocator.getPositionStream().listen((myPos) {
      final user = Rider(
          id: '12',
          name: 'ify',
          position: geo
              .point(latitude: myPos.latitude, longitude: myPos.longitude)
              .data);
      database.updateMyLocation(user);
    });
  }

  getNearbyDrivers() async {
    Geolocator.getPositionStream().listen((myLocation) {
      final myPos = LatLng(myLocation.latitude, myLocation.longitude);
      addSearchRadius(myPos);
      database.getNearbyDrivers(myPos).listen((drivers) {
        for (var driver in drivers) {
          setState(() {
            markers[MarkerId(driver.id)] = Marker(
              icon: icon,
              markerId: MarkerId(driver.id),
              position: LatLng(driver.position['geopoint'].latitude,
                  driver.position['geopoint'].longitude),
            );
          });
        }
      });
    });
  }

  Future<double> calculateDistance(LatLng destPosition) async {
    Position myPos;
    if (myLocation == null) {
      myPos = await Geolocator.getCurrentPosition();
    } else {
      myPos = myLocation!;
    }
    return Geolocator.distanceBetween(myPos.latitude, myPos.longitude,
        destPosition.latitude, destPosition.longitude);
  }

  initPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    myLocation = await Geolocator.getCurrentPosition();
    setState(() {});
    return myLocation;
  }

  animateToMyLocation() async {
    Position myPos;
    if (myLocation == null) {
      myPos = await Geolocator.getCurrentPosition();
    } else {
      myPos = myLocation!;
    }
    GoogleMapController controller = await completer.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 13.2,
          target: LatLng(myPos.latitude, myPos.longitude),
        ),
      ),
    );
  }

  addSearchRadius(LatLng myPos) {
    final circleId = CircleId(userName);
    searchRadius[CircleId(userName)] = Circle(
      fillColor: Colors.blue.withOpacity(0.1),
      strokeWidth: 1,
      strokeColor: Colors.blue.withOpacity(0.4),
      circleId: circleId,
      radius: 3000,
      center: LatLng(myPos.latitude, myPos.longitude),
    );
  }

  addPolyline(List<LatLng> polylineCoordinates) {
    final polylineId = PolylineId(DateTime.now().toIso8601String());
    final Polyline route = Polyline(
      color: Colors.red,
      polylineId: polylineId,
      width: 3,
      points: polylineCoordinates,
    );
    setState(() {
      polyLines.clear();
      polyLines[polylineId] = route;
    });
  }
}
