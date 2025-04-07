class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({this.message = 'Server error occurred', this.statusCode});

  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Network error occurred'});

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;

  ValidationException({this.message = 'Validation error occurred'});

  @override
  String toString() => 'ValidationException: $message';
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException({this.message = 'Authentication error occurred'});

  @override
  String toString() => 'AuthenticationException: $message';
} 