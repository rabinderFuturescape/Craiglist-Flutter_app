import 'package:flutter/material.dart';
import '../../../features/product/presentation/pages/product_listing_page.dart';
import '../../../features/looking_for/presentation/pages/looking_for_list_page.dart';
import '../widgets/layout/app_drawer.dart';
import '../../../core/theme/app_colors.dart';

/// Main navigation page with tabs for "Offer to Sell" and "Looking to Buy" sections
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> with SingleTickerProviderStateMixin {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Craigslist Flutter App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.sell),
              text: 'Offer to Sell',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: 'Looking to Buy',
            ),
          ],
          indicatorColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
          labelColor: isDarkMode ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Offer to Sell Tab
          ProductListingTabView(),
          
          // Looking to Buy Tab
          LookingForTabView(),
        ],
      ),
    );
  }
}

/// Tab view for the "Offer to Sell" section
class ProductListingTabView extends StatelessWidget {
  const ProductListingTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProductListingPage(isTabView: true);
  }
}

/// Tab view for the "Looking to Buy" section
class LookingForTabView extends StatelessWidget {
  const LookingForTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LookingForListPage(isTabView: true);
  }
}
