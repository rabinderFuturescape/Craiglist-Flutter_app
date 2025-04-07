import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An error occurred'});

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure({String message = 'Authentication failed'}) : super(message: message);
}

class ServerFailure extends Failure {
  final int? code;

  const ServerFailure({String message = 'Server error', this.code}) : super(message: message);

  @override
  List<Object?> get props => [message, code];
}

class CacheFailure extends Failure {
  const CacheFailure({String message = 'Cache error'}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'Network error'}) : super(message: message);
}
