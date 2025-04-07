import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Abstract class for checking network connectivity
abstract class NetworkInfo {
  /// Returns true if the device has an active internet connection
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo that uses InternetConnectionChecker
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
