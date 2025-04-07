import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/pages/create_listing_page.dart';

// Import standardized components
import '../../../../core/presentation/widgets/layout/app_bar_widget.dart';
import '../../../../core/presentation/widgets/layout/loading_indicator.dart';
import '../../../../core/presentation/widgets/layout/empty_state.dart';
import '../../../../core/presentation/widgets/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'My Profile',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Listings'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Listings Tab

          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoaded) {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  final myListings = state.products
                      .where((product) => product.sellerId == authState.userId)
                      .toList();

                  if (myListings.isEmpty) {
                    return EmptyState(
                      message: 'You haven\'t posted any listings yet',
                      buttonText: 'Create a Listing',
                      icon: Icons.post_add,
                      onAction: () {
                        Navigator.pushNamed(context, '/create-listing');
                      },
                    );
                  }

                  return ListView.builder(
                    itemCount: myListings.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final product = myListings[index];
                      return ListingCard(
                        product: product,
                        onEdit: () {
                          // Navigate to edit listing page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateListingPage(
                                editProduct: product,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Listing'),
                              content: const Text(
                                  'Are you sure you want to delete this listing?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Remove the product using the bloc
                                    context.read<ProductBloc>().add(
                                          RemoveProduct(product.id),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Listing deleted successfully'),
                                      ),
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              }

              return const LoadingIndicator(message: 'Loading your listings...');
            },
          ),

          // Saved Listings Tab
          const EmptyState(
            message: 'Saved listings feature coming soon',
            icon: Icons.bookmark_border,
          ),
        ],
      ),
    );
  }
}

// A custom card for the user's listings
class ListingCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ListingCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Listing image
          if (product.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  product.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: AppTextStyles.subtitle1.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.subtitle1.copyWith(
                        color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2.copyWith(color: secondaryTextColor),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? AppColors.success.withAlpha(51)
                            : AppColors.warning.withAlpha(51),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.isAvailable ? 'Active' : 'Draft',
                        style: AppTextStyles.caption.copyWith(
                          color: product.isAvailable ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
