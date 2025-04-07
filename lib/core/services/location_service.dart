import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Get the current location of the device
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  /// Search for locations by query
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final response = await http.get(
      Uri.parse(
          '$_nominatimBaseUrl/search?q=$encodedQuery&format=json&limit=5'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to search location');
    }
  }

  /// Get address from coordinates
  Future<String> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Error getting address';
    }
  }

  /// Calculate distance between two points
  double calculateDistance(LatLng point1, LatLng point2) {
    return const Distance().as(
      LengthUnit.Kilometer,
      point1,
      point2,
    );
  }

  /// Get nearby locations within radius
  Future<List<Map<String, dynamic>>> getNearbyLocations(
    LatLng center,
    double radiusKm,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_nominatimBaseUrl/reverse?lat=${center.latitude}&lon=${center.longitude}&format=json&zoom=16',
      ),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return [data];
    } else {
      throw Exception('Failed to get nearby locations');
    }
  }
}
