import 'package:location/location.dart';

class LocationServiceState {
  LocationData? locationData;
  String? error;
  LocationServiceState({
    this.locationData,
    this.error,
  });

  factory LocationServiceState.success(LocationData locationData) =>
      LocationServiceState(locationData: locationData);
  factory LocationServiceState.error(String error) =>
      LocationServiceState(error: error);
  factory LocationServiceState.loading() => LocationServiceState();
}
