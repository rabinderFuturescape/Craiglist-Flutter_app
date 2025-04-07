import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/location_service.dart';
import 'location_map.dart';

class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerDialog({
    Key? key,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  LatLng? _selectedLocation;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _updateAddress(_selectedLocation!);
    }
  }

  Future<void> _updateAddress(LatLng location) async {
    final address = await _locationService.getAddressFromCoordinates(location);
    setState(() {
      _selectedAddress = address;
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      final results = await _locationService.searchLocation(query);
      setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () async {
                    try {
                      final position =
                          await _locationService.getCurrentLocation();
                      final location = LatLng(
                        position.latitude,
                        position.longitude,
                      );
                      setState(() => _selectedLocation = location);
                      await _updateAddress(location);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                ),
              ),
              onChanged: _searchLocation,
            ),
            if (_searchResults.isNotEmpty)
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      title: Text(result['display_name'] ?? ''),
                      onTap: () {
                        final lat = double.tryParse(result['lat'] ?? '');
                        final lon = double.tryParse(result['lon'] ?? '');
                        if (lat != null && lon != null) {
                          setState(() {
                            _selectedLocation = LatLng(lat, lon);
                            _searchResults = [];
                            _searchController.clear();
                          });
                          _updateAddress(_selectedLocation!);
                        }
                      },
                    );
                  },
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: LocationMap(
                  initialPosition: _selectedLocation,
                  markers: _selectedLocation != null
                      ? [_selectedLocation!]
                      : const [],
                  onTap: (location) {
                    setState(() => _selectedLocation = location);
                    _updateAddress(location);
                  },
                ),
              ),
            ),
            if (_selectedAddress.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _selectedAddress,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedLocation != null
                      ? () => Navigator.pop(
                            context,
                            {
                              'location': _selectedLocation,
                              'address': _selectedAddress,
                            },
                          )
                      : null,
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
