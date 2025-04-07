import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/pages/sign_in_page.dart';
import '../../../../features/auth/presentation/pages/user_profile_page.dart';
import '../../../../features/product/presentation/pages/product_listing_page.dart';
import '../../../../features/cart/presentation/pages/cart_page.dart';
import '../../../../features/looking_for/presentation/pages/looking_for_list_page.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/text_styles.dart';

/// A drawer widget that provides navigation to different parts of the app
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer header with user info or sign in button
              _buildDrawerHeader(context, state, isDarkMode),
              
              // Home / Products
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                ),
                title: Text(
                  'Home',
                  style: AppTextStyles.body1.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/products');
                },
              ),
              
              // Looking For
              ListTile(
                leading: Icon(
                  Icons.search,
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                ),
                title: Text(
                  'Looking For',
                  style: AppTextStyles.body1.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/looking-for');
                },
              ),
              
              // Cart
              ListTile(
                leading: Icon(
                  Icons.shopping_cart,
                  color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                ),
                title: Text(
                  'Cart',
                  style: AppTextStyles.body1.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              
              const Divider(),
              
              // Profile (only shown if authenticated)
              if (state is Authenticated)
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  ),
                  title: Text(
                    'My Profile',
                    style: AppTextStyles.body1.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfilePage(),
                      ),
                    );
                  },
                ),
              
              // Sign out (only shown if authenticated)
              if (state is Authenticated)
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: isDarkMode ? Colors.redAccent : Colors.red,
                  ),
                  title: Text(
                    'Sign Out',
                    style: AppTextStyles.body1.copyWith(
                      color: isDarkMode ? Colors.redAccent : Colors.red,
                    ),
                  ),
                  onTap: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close drawer
                              context.read<AuthBloc>().add(SignOut());
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              
              // Sign in (only shown if not authenticated)
              if (state is! Authenticated)
                ListTile(
                  leading: Icon(
                    Icons.login,
                    color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
                  ),
                  title: Text(
                    'Sign In',
                    style: AppTextStyles.body1.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInPage(),
                      ),
                    );
                  },
                ),
              
              const Divider(),
              
              // About
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                title: Text(
                  'About',
                  style: AppTextStyles.body1.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Show about dialog
                  showAboutDialog(
                    context: context,
                    applicationName: 'Craigslist Flutter App',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(size: 32),
                    applicationLegalese: '© 2023 Futurescape Tech',
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'A marketplace app built with Flutter and Clean Architecture.',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build the drawer header based on authentication state
  Widget _buildDrawerHeader(BuildContext context, AuthState state, bool isDarkMode) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo
          const FlutterLogo(size: 48),
          const SizedBox(height: 16),
          
          // User info or app name
          if (state is Authenticated)
            Text(
              state.displayName ?? 'User ${state.userId}',
              style: AppTextStyles.headline6.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              'Craigslist Flutter App',
              style: AppTextStyles.headline6.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          
          // User email or tagline
          if (state is Authenticated && state.email != null)
            Text(
              state.email!,
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            )
          else
            Text(
              'Buy and sell with ease',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }
}
