import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../../../../core/presentation/widgets/inputs/app_text_field.dart';
import '../../../../core/presentation/widgets/buttons/primary_button.dart';
import '../../../../core/presentation/widgets/buttons/secondary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({Key? key}) : super(key: key);

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  String _selectedSort = 'Newest First';
  RangeValues _priceRange = const RangeValues(0, 10000);

  final List<String> _categories = [
    'All Categories',
    'Electronics',
    'Furniture',
    'Home Goods',
    'Clothing',
    'Sports Equipment',
    'Automotive',
    'Books',
    'Toys & Games',
    'Other',
  ];

  final List<String> _sortOptions = [
    'Newest First',
    'Oldest First',
    'Price: Low to High',
    'Price: High to Low',
    'Most Relevant',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => DraggableScrollableSheet(
          initialChildSize: screenHeight > 900 ? 0.5 : 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width > 600 ? 32.0 : 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.borderDark : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Filter Options',
                    style: AppTextStyles.headline6.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Selection
                  Text(
                    'Category',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode ? AppColors.borderDark : AppColors.border,
                      ),
                      color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        dropdownColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: AppTextStyles.body1.copyWith(
                                color: isDarkMode ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Range
                  Text(
                    'Price Range',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    activeColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                    inactiveColor: isDarkMode
                        ? AppColors.primaryDark.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.3),
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.round()}',
                        style: AppTextStyles.body2.copyWith(
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '\$${_priceRange.end.round()}',
                        style: AppTextStyles.body2.copyWith(
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sort By
                  Text(
                    'Sort By',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode ? AppColors.borderDark : AppColors.border,
                      ),
                      color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        dropdownColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(
                              option,
                              style: AppTextStyles.body1.copyWith(
                                color: isDarkMode ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSort = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Apply and Reset buttons
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Reset',
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'All Categories';
                              _selectedSort = 'Newest First';
                              _priceRange = const RangeValues(0, 10000);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Apply',
                          onPressed: _applyFilters,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 24.0 : 16.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: isWideScreen ? 3 : 4,
                child: AppTextField(
                  controller: _searchController,
                  hint: 'Search listings...',
                  prefixIcon: Icons.search,
                  suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
                  onSuffixIconPressed: _searchController.text.isNotEmpty
                      ? () {
                          _searchController.clear();
                          context.read<ProductBloc>().add(const SearchProducts(''));
                        }
                      : null,
                  onChanged: (value) {
                    setState(() {}); // Update to show/hide clear button
                    context.read<ProductBloc>().add(SearchProducts(value));
                  },
                  onSubmitted: (value) {
                    context.read<ProductBloc>().add(SearchProducts(value));
                  },
                ),
              ),
              SizedBox(width: isWideScreen ? 16.0 : 8.0),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                  tooltip: 'Filter',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilters() {
    context.read<ProductBloc>().add(
          FilterProducts(
            category: _selectedCategory != 'All Categories'
                ? _selectedCategory
                : null,
            priceRange: _priceRange,
            sortOption: _selectedSort,
          ),
        );
    Navigator.pop(context);
  }
}
