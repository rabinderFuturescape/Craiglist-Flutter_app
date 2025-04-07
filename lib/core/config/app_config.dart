class AppConfig {
  static const String appName = 'Clean Architecture App';
  static const String apiBaseUrl = 'https://api.example.com';
  
  // Add other configuration constants as needed
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Environment configuration
  static const bool isDevelopment = true;
  static const bool isProduction = false;
} 