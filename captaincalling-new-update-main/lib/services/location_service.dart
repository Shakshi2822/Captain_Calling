import 'package:geolocator/geolocator.dart';

// Function to get the current location
Future<Position> getCurrentLocation() async {
  await Geolocator.requestPermission();  // Request permission to access location
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

// Function to calculate distance between two geographical points
double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
  return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
}
