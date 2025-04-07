import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/sign_in.dart' as sign_in;
import 'features/auth/domain/usecases/sign_up.dart' as sign_up;
import 'features/auth/presentation/bloc/auth_bloc.dart' as auth_bloc;
import 'features/product/presentation/bloc/product_bloc.dart' as product_bloc;
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/product/presentation/pages/product_listing_page.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/services/authentication_service.dart';
import 'features/auth/data/services/authentication_service_impl.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'core/services/api_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/token_manager.dart';
import 'core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/data/datasources/product_remote_data_source.dart';

/// Main entry point of the application.
///
/// This initializes all dependencies and starts the app with proper authentication flow.
/// The app will check authentication status on startup and direct users to the
/// appropriate screen.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Set up dependencies
  final secureStorage = SecureStorageService();
  final tokenManager = TokenManager(secureStorage: secureStorage);
  await tokenManager.initialize(); // Initialize token manager

  final apiService = ApiService(secureStorage: secureStorage, tokenManager: tokenManager);
  final networkInfo = NetworkInfoImpl(InternetConnectionChecker());

  // Set up data sources
  final productRemoteDataSource = ProductRemoteDataSourceImpl(apiService: apiService);

  // Set up repositories
  final productRepository = ProductRepositoryImpl(
    remoteDataSource: productRemoteDataSource,
    networkInfo: networkInfo,
  );

  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  final authRepository = AuthRepositoryImpl(authLocalDataSource);
  final signIn = sign_in.SignIn(authRepository);
  final signUp = sign_up.SignUp(authRepository);
  final authService = AuthenticationServiceImpl(
    secureStorage: secureStorage,
    tokenManager: tokenManager,
  );

  runApp(MyApp(
    signIn: signIn,
    signUp: signUp,
    authService: authService,
    productRepository: productRepository,
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

  const MyApp({
    Key? key,
    required this.signIn,
    required this.signUp,
    required this.authService,
    required this.productRepository,
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
      ],
      child: MaterialApp(
        title: 'Craigslist Flutter App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const ProductListingPage(),
        // Routes without the redundant '/' entry
        routes: {
          '/products': (context) => const ProductListingPage(),
          '/cart': (context) => const CartPage(),
        },
      ),
    );
  }
}
