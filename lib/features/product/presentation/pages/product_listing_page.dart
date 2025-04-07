import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import 'listing_details_page.dart';
import '../../domain/entities/product.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import 'create_listing_page.dart';
import '../widgets/search_filter_bar.dart';

// Import standardized components
import '../../../../core/presentation/widgets/layout/app_bar_widget.dart';
import '../../../../core/presentation/widgets/layout/app_drawer.dart';
import '../../../../core/presentation/widgets/layout/loading_indicator.dart';
import '../../../../core/presentation/widgets/layout/error_display.dart';
import '../../../../core/presentation/widgets/layout/empty_state.dart';
import '../../../../core/presentation/widgets/layout/responsive_grid.dart';
import '../../../../core/presentation/widgets/cards/product_card.dart';

class ProductListingPage extends StatelessWidget {
  const ProductListingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBarWidget(
            title: 'Products',
            actions: [
              IconButton(
                icon: Icon(
                  state.isGridView ? Icons.view_list : Icons.grid_view,
                ),
                onPressed: () {
                  context.read<ProductBloc>().add(const ToggleViewMode());
                },
                tooltip: state.isGridView
                    ? 'Switch to List View'
                    : 'Switch to Grid View',
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filter Bar
              const SearchFilterBar(),

              // Product List with Refresh Indicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProductBloc>().add(const LoadProducts());
                  },
                  child: _buildBody(context, state),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateListingPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductState state) {
    if (state is ProductInitial) {
      context.read<ProductBloc>().add(const LoadProducts());
      return const LoadingIndicator(message: 'Loading products...');
    }

    if (state is ProductLoading) {
      return const LoadingIndicator(message: 'Loading products...');
    }

    if (state is ProductError) {
      return ErrorDisplay(
        message: 'Error: ${state.message}',
        buttonText: 'Try Again',
        onRetry: () {
          context.read<ProductBloc>().add(const LoadProducts());
        },
      );
    }

    if (state is ProductLoaded) {
      if (state.products.isEmpty) {
        return EmptyState(
          message: 'No listings found',
          buttonText: 'Create a Listing',
          icon: Icons.sentiment_dissatisfied,
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateListingPage(),
              ),
            );
          },
        );
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: state.isGridView
            ? _buildGridView(context, state.products)
            : _buildListView(context, state.products),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGridView(BuildContext context, List<Product> products) {
    return ResponsiveGrid(
      children: products.map((product) {
        return ProductCard(
          product: product,
          isGridView: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListingDetailsPage(
                  product: product,
                ),
              ),
            );
          },
          onFavorite: () {
            // TODO: Implement favorite functionality
          },
        );
      }).toList(),
    );
  }

  Widget _buildListView(BuildContext context, List<Product> products) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          isGridView: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListingDetailsPage(
                  product: products[index],
                ),
              ),
            );
          },
          onFavorite: () {
            // TODO: Implement favorite functionality
          },
        );
      },
    );
  }
}
