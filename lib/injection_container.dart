import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/services/api_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/token_manager.dart';

import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_user.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/repositories/product_repository.dart';
import 'features/product/domain/usecases/create_product.dart';
import 'features/product/domain/usecases/get_product.dart';
import 'features/product/domain/usecases/get_products.dart';
import 'features/product/domain/usecases/remove_product.dart';
import 'features/product/domain/usecases/update_product.dart';
import 'features/product/presentation/bloc/product_bloc.dart';

import 'features/cart/data/datasources/cart_local_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/domain/usecases/add_to_cart.dart';
import 'features/cart/domain/usecases/get_cart.dart';
import 'features/cart/domain/usecases/remove_from_cart.dart';
import 'features/cart/domain/usecases/update_cart_item.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

import 'features/looking_for/data/datasources/looking_for_remote_data_source.dart';
import 'features/looking_for/data/datasources/looking_for_remote_data_source_impl.dart';
import 'features/looking_for/data/repositories/looking_for_repository_impl.dart';
import 'features/looking_for/domain/repositories/looking_for_repository.dart';
import 'features/looking_for/domain/usecases/check_expired_items.dart';
import 'features/looking_for/domain/usecases/create_looking_for_item.dart';
import 'features/looking_for/domain/usecases/delete_looking_for_item.dart';
import 'features/looking_for/domain/usecases/get_looking_for_items.dart';
import 'features/looking_for/domain/usecases/get_user_looking_for_items.dart';
import 'features/looking_for/domain/usecases/update_looking_for_item.dart';
import 'features/looking_for/presentation/bloc/looking_for_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      getUser: sl(),
      signIn: sl(),
      signOut: sl(),
      signUp: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUser(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiService: sl(),
      tokenManager: sl(),
    ),
  );

  //! Features - Product
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      getProducts: sl(),
      getProduct: sl(),
      createProduct: sl(),
      updateProduct: sl(),
      removeProduct: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => GetProduct(sl()));
  sl.registerLazySingleton(() => CreateProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => RemoveProduct(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      apiService: sl(),
    ),
  );

  //! Features - Cart
  // Bloc
  sl.registerFactory(
    () => CartBloc(
      getCart: sl(),
      addToCart: sl(),
      removeFromCart: sl(),
      updateCartItem: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => UpdateCartItem(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  //! Features - Looking For
  // Bloc
  sl.registerFactory(
    () => LookingForBloc(
      getLookingForItems: sl(),
      getUserLookingForItems: sl(),
      createLookingForItem: sl(),
      updateLookingForItem: sl(),
      deleteLookingForItem: sl(),
      checkExpiredItems: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLookingForItems(sl()));
  sl.registerLazySingleton(() => GetUserLookingForItems(sl()));
  sl.registerLazySingleton(() => CreateLookingForItem(sl()));
  sl.registerLazySingleton(() => UpdateLookingForItem(sl()));
  sl.registerLazySingleton(() => DeleteLookingForItem(sl()));
  sl.registerLazySingleton(() => CheckExpiredItems(sl()));

  // Repository
  sl.registerLazySingleton<LookingForRepository>(
    () => LookingForRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<LookingForRemoteDataSource>(
    () => LookingForRemoteDataSourceImpl(
      apiService: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  sl.registerLazySingleton<ApiService>(
    () => ApiServiceImpl(
      client: sl(),
      tokenManager: sl(),
    ),
  );

  sl.registerLazySingleton<TokenManager>(
    () => TokenManagerImpl(
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
