import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/services/authentication_service.dart';
import '../../domain/usecases/sign_in.dart' as sign_in;
import '../../domain/usecases/sign_up.dart' as sign_up;

/// Base class for all authentication-related events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when a user attempts to sign in.
class SignIn extends AuthEvent {
  final String email;
  final String password;

  const SignIn({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event triggered when a user attempts to sign up.
class SignUp extends AuthEvent {
  final String email;
  final String password;

  const SignUp({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Event triggered when a user signs out.
class SignOut extends AuthEvent {}

/// Event triggered when the app needs to check if a user is already authenticated.
/// This is typically called when the app starts.
class CheckAuthStatusRequested extends AuthEvent {}

/// Base class for all authentication-related states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// The initial state of the authentication bloc.
class AuthInitial extends AuthState {}

/// State indicating that an authentication process is in progress.
class AuthLoading extends AuthState {}

/// State indicating that the user is authenticated.
class Authenticated extends AuthState {
  final String userId;
  final String? displayName;
  final String? email;
  final String? phone;

  const Authenticated({
    required this.userId,
    this.displayName,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [userId, displayName, email, phone];
}

/// State indicating that the user is not authenticated.
class Unauthenticated extends AuthState {}

/// State indicating that an authentication error occurred.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

/// BLoC responsible for managing authentication state throughout the app.
///
/// This handles sign-in, sign-up, sign-out, and checking authentication status.
/// The authentication flow is as follows:
/// 1. App starts and triggers [CheckAuthStatusRequested]
/// 2. BLoC checks if the user is already authenticated
/// 3. If authenticated, it emits [Authenticated] state
/// 4. If not authenticated, it emits [Unauthenticated] state
/// 5. UI redirects based on the current state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticationService _authService;
  final sign_in.SignIn signIn;
  final sign_up.SignUp signUp;

  AuthBloc({
    required AuthenticationService authService,
    required this.signIn,
    required this.signUp,
  })  : _authService = authService,
        super(AuthInitial()) {
    on<SignIn>(_onSignIn);
    on<SignUp>(_onSignUp);
    on<SignOut>(_onSignOut);
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
  }

  /// Handles the sign-in process.
  Future<void> _onSignIn(SignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authService.signIn(event.email, event.password);
      final user = await _authService.getCurrentUser();

      emit(Authenticated(
        userId: result['user_id'] ?? '',
        displayName: user?.name ?? result['displayName'] ?? '',
        email: user?.email ?? event.email,
        phone: user?.phone,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handles the sign-up process.
  Future<void> _onSignUp(SignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authService.signUp(event.email, event.password);
      final user = await _authService.getCurrentUser();

      emit(Authenticated(
        userId: result['user_id'] ?? '',
        displayName: user?.name ?? result['displayName'] ?? '',
        email: user?.email ?? event.email,
        phone: user?.phone,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handles the sign-out process.
  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      if (state is Authenticated) {
        await _authService.signOut((state as Authenticated).userId);
      }
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Checks if the user is already authenticated.
  ///
  /// Checks if the user has a valid token and retrieves user data if available.
  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();

        if (user != null) {
          emit(Authenticated(
            userId: user.id,
            displayName: user.name,
            email: user.email,
            phone: user.phone,
          ));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}
