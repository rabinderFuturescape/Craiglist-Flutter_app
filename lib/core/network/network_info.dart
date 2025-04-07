import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Abstract class for checking network connectivity
abstract class NetworkInfo {
  /// Returns true if the device has an active internet connection
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo that uses InternetConnectionChecker
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker? connectionChecker;

  NetworkInfoImpl([this.connectionChecker]);

  @override
  Future<bool> get isConnected {
    // For web platforms, always return true since InternetConnectionChecker is not supported
    if (kIsWeb || connectionChecker == null) {
      return Future.value(true);
    }
    return connectionChecker!.hasConnection;
  }
}

/// Web-specific implementation of NetworkInfo that always returns true
class WebNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected => Future.value(true);
}
