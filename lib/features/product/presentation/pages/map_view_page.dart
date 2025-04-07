import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/presentation/widgets/loading_animation.dart';
import '../../../../core/presentation/widgets/location_map.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_map_card.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key}) : super(key: key);

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  Product? _selectedProduct;
  LatLng? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // TODO: Get current location and center map
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: LoadingAnimation());
          }

          if (state is ProductError) {
            return Center(child: Text(state.message));
          }

          if (state is ProductLoaded) {
            final products = state.products.where((p) => p.coordinates != null);
            if (products.isEmpty) {
              return const Center(
                child: Text('No listings with location data available'),
              );
            }

            return Stack(
              children: [
                LocationMap(
                  initialPosition: _currentLocation ??
                      products.first.coordinates ??
                      const LatLng(0, 0),
                  markers:
                      products.map((product) => product.coordinates!).toList(),
                  onTap: (_) => setState(() => _selectedProduct = null),
                ),
                if (_selectedProduct != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ProductMapCard(
                      product: _selectedProduct!,
                      onClose: () => setState(() => _selectedProduct = null),
                    ),
                  ),
              ],
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}
