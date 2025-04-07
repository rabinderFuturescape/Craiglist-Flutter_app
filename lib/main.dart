import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/sign_in.dart' as sign_in;
import 'features/auth/domain/usecases/sign_up.dart' as sign_up;
import 'features/auth/presentation/bloc/auth_bloc.dart' as auth_bloc;
import 'features/product/presentation/bloc/product_bloc.dart' as product_bloc;
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/product/presentation/pages/product_listing_page.dart';
import 'core/presentation/pages/main_navigation_page.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/services/authentication_service.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/token_manager.dart';
import 'core/network/network_info.dart';
import 'core/services/supabase_client.dart';
import 'features/auth/data/services/supabase_auth_service.dart';
import 'features/product/data/datasources/product_supabase_data_source.dart';
import 'features/looking_for/data/datasources/looking_for_supabase_data_source.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/looking_for/data/repositories/looking_for_repository_impl.dart';

import 'features/looking_for/domain/usecases/check_expired_items.dart';
import 'features/looking_for/domain/usecases/create_looking_for_item.dart';
import 'features/looking_for/domain/usecases/delete_looking_for_item.dart';
import 'features/looking_for/domain/usecases/get_looking_for_items.dart';
import 'features/looking_for/domain/usecases/get_user_looking_for_items.dart';
import 'features/looking_for/domain/usecases/update_looking_for_item.dart';
import 'features/looking_for/presentation/bloc/looking_for_bloc.dart';
import 'features/looking_for/presentation/pages/looking_for_list_page.dart';


/// Main entry point of the application.
///
/// This initializes all dependencies and starts the app with proper authentication flow.
/// The app will check authentication status on startup and direct users to the
/// appropriate screen.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await AppSupabaseClient.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();

  // Set up dependencies
  final secureStorage = SecureStorageService();
  final tokenManager = TokenManager(secureStorage: secureStorage);
  await tokenManager.initialize(); // Initialize token manager

  // Create network info based on platform
  final networkInfo = kIsWeb
      ? WebNetworkInfo()
      : NetworkInfoImpl(InternetConnectionChecker());

  // Set up Supabase client
  final supabaseClient = AppSupabaseClient.instance;

  // Set up authentication service
  final authService = SupabaseAuthService(supabaseClient: supabaseClient);

  // Set up data sources
  final productRemoteDataSource = ProductSupabaseDataSource(supabaseClient: supabaseClient);
  final lookingForRemoteDataSource = LookingForSupabaseDataSource(supabaseClient: supabaseClient);

  // Set up repositories
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: productRemoteDataSource,
    networkInfo: networkInfo,
  );

  final lookingForRepository = LookingForRepositoryImpl(
    remoteDataSource: lookingForRemoteDataSource,
    networkInfo: networkInfo,
  );

  // Set up Looking For use cases
  final getLookingForItems = GetLookingForItems(lookingForRepository);
  final getUserLookingForItems = GetUserLookingForItems(lookingForRepository);
  final createLookingForItem = CreateLookingForItem(lookingForRepository);
  final updateLookingForItem = UpdateLookingForItem(lookingForRepository);
  final deleteLookingForItem = DeleteLookingForItem(lookingForRepository);
  final checkExpiredItems = CheckExpiredItems(lookingForRepository);

  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  final authRepository = AuthRepositoryImpl(authLocalDataSource);
  final signIn = sign_in.SignIn(authRepository);
  final signUp = sign_up.SignUp(authRepository);

  runApp(MyApp(
    signIn: signIn,
    signUp: signUp,
    authService: authService,
    productRepository: productRepository,
    getLookingForItems: getLookingForItems,
    getUserLookingForItems: getUserLookingForItems,
    createLookingForItem: createLookingForItem,
    updateLookingForItem: updateLookingForItem,
    deleteLookingForItem: deleteLookingForItem,
    checkExpiredItems: checkExpiredItems,
  ));
}

/// Root widget of the application.
///
/// This sets up the BLoC providers and main MaterialApp with the proper
/// routing based on authentication state.
class MyApp extends StatelessWidget {
  final sign_in.SignIn signIn;
  final sign_up.SignUp signUp;
  final AuthenticationService authService;
  final ProductRepository productRepository;
  final GetLookingForItems getLookingForItems;
  final GetUserLookingForItems getUserLookingForItems;
  final CreateLookingForItem createLookingForItem;
  final UpdateLookingForItem updateLookingForItem;
  final DeleteLookingForItem deleteLookingForItem;
  final CheckExpiredItems checkExpiredItems;

  const MyApp({
    Key? key,
    required this.signIn,
    required this.signUp,
    required this.authService,
    required this.productRepository,
    required this.getLookingForItems,
    required this.getUserLookingForItems,
    required this.createLookingForItem,
    required this.updateLookingForItem,
    required this.deleteLookingForItem,
    required this.checkExpiredItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<auth_bloc.AuthBloc>(
          create: (context) => auth_bloc.AuthBloc(
            authService: authService,
            signIn: signIn,
            signUp: signUp,
          ),
        ),
        BlocProvider<product_bloc.ProductBloc>(
          create: (context) => product_bloc.ProductBloc(productRepository: productRepository)
            ..add(const product_bloc.LoadProducts()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(),
        ),
        BlocProvider<LookingForBloc>(
          create: (context) => LookingForBloc(
            getLookingForItems: getLookingForItems,
            getUserLookingForItems: getUserLookingForItems,
            createLookingForItem: createLookingForItem,
            updateLookingForItem: updateLookingForItem,
            deleteLookingForItem: deleteLookingForItem,
            checkExpiredItems: checkExpiredItems,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Craigslist Flutter App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigationPage(),
        // Routes without the redundant '/' entry
        routes: {
          '/home': (context) => const MainNavigationPage(),
          '/products': (context) => const ProductListingPage(),
          '/cart': (context) => const CartPage(),
          '/looking-for': (context) => const LookingForListPage(),
        },
      ),
    );
  }
}
