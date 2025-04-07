import 'package:latlong2/latlong.dart';

class LocationResult {
  final String address;
  final LatLng coordinates;

  const LocationResult({
    required this.address,
    required this.coordinates,
  });
}
