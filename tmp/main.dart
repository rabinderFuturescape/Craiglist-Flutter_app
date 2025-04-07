import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/sign_in.dart' as sign_in;
import 'features/auth/domain/usecases/sign_up.dart' as sign_up;
import 'features/auth/presentation/bloc/auth_bloc.dart' as auth_bloc;
import 'features/product/presentation/bloc/product_bloc.dart' as product_bloc;
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/services/authentication_service.dart';
import 'features/auth/data/services/authentication_service_impl.dart';
import 'core/presentation/pages/main_navigation.dart';
import 'features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'features/ai_assistant/di/ai_assistant_injection_container.dart'
    as ai_di;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'core/network/network_info.dart';
import 'core/services/ai_service.dart';
import 'features/ai_assistant/data/datasources/ai_assistant_remote_data_source.dart';
import 'features/ai_assistant/data/datasources/ai_assistant_local_data_source.dart';
import 'features/ai_assistant/data/repositories/ai_assistant_repository_impl.dart';
import 'features/ai_assistant/domain/repositories/ai_assistant_repository.dart';
import 'features/ai_assistant/domain/usecases/get_chat_completion.dart';
import 'features/ai_assistant/domain/usecases/generate_image.dart';
import 'features/ai_assistant/domain/usecases/get_suggested_title.dart';
import 'features/ai_assistant/domain/usecases/load_chat_history.dart';
import 'features/ai_assistant/domain/usecases/save_chat_history.dart';

/// Main entry point of the application.
///
/// This initializes all dependencies and starts the app with proper authentication flow.
/// The app will check authentication status on startup and direct users to the
/// appropriate screen.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  // Set up dependencies
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  final authRepository = AuthRepositoryImpl(authLocalDataSource);
  final signIn = sign_in.SignIn(authRepository);
  final signUp = sign_up.SignUp(authRepository);
  final authService = AuthenticationServiceImpl(authRepository);

  // Initialize AI Assistant dependencies
  await ai_di.init();

  // Set up AI Assistant dependencies (simplified for direct usage)
  final networkInfo = NetworkInfoImpl(InternetConnectionChecker());
  final aiService = AIService(
      apiKey: const String.fromEnvironment('OPENAI_API_KEY',
          defaultValue: 'sk-your-api-key'));
  final aiRemoteDataSource =
      AIAssistantRemoteDataSourceImpl(aiService: aiService);
  final aiLocalDataSource =
      AIAssistantLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final aiRepository = AIAssistantRepositoryImpl(
    remoteDataSource: aiRemoteDataSource,
    localDataSource: aiLocalDataSource,
    networkInfo: networkInfo,
  );

  // Use cases
  final getChatCompletion = GetChatCompletion(aiRepository);
  final generateImage = GenerateImage(aiRepository);
  final getSuggestedTitle = GetSuggestedTitle(aiRepository);
  final loadChatHistory = LoadChatHistory(aiRepository);
  final saveChatHistory = SaveChatHistory(aiRepository);

  runApp(MyApp(
    signIn: signIn,
    signUp: signUp,
    authService: authService,
    getChatCompletion: getChatCompletion,
    generateImage: generateImage,
    getSuggestedTitle: getSuggestedTitle,
    loadChatHistory: loadChatHistory,
    saveChatHistory: saveChatHistory,
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
  final GetChatCompletion getChatCompletion;
  final GenerateImage generateImage;
  final GetSuggestedTitle getSuggestedTitle;
  final LoadChatHistory loadChatHistory;
  final SaveChatHistory saveChatHistory;

  const MyApp({
    Key? key,
    required this.signIn,
    required this.signUp,
    required this.authService,
    required this.getChatCompletion,
    required this.generateImage,
    required this.getSuggestedTitle,
    required this.loadChatHistory,
    required this.saveChatHistory,
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
          create: (context) => product_bloc.ProductBloc()
            ..add(const product_bloc.LoadProducts()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(),
        ),
        BlocProvider<AIAssistantBloc>(
          create: (context) => AIAssistantBloc(
            getChatCompletion: getChatCompletion,
            generateImage: generateImage,
            getSuggestedTitle: getSuggestedTitle,
            loadChatHistory: loadChatHistory,
            saveChatHistory: saveChatHistory,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Craigslist Flutter App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigation(),
        routes: {
          '/home': (context) => const MainNavigation(),
        },
      ),
    );
  }
}
