import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMap extends StatelessWidget {
  static const LatLng defaultLocation =
      LatLng(19.7515, 75.7139); // Center of Maharashtra
  static const double defaultZoom = 7.0;

  final LatLng? initialPosition;
  final List<LatLng> markers;
  final Function(LatLng) onTap;

  const LocationMap({
    Key? key,
    this.initialPosition,
    required this.markers,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: initialPosition ?? defaultLocation,
        zoom: defaultZoom,
        onTap: (_, point) => onTap(point),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: markers
              .map(
                (point) => Marker(
                  point: point,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                  width: 40,
                  height: 40,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
