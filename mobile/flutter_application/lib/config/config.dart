class Config {
  // Development URLs
  static const String androidEmulatorUrl =
      'http://10.0.2.2:5000/api'; // Android emulator
  static const String iosSimulatorUrl =
      'http://localhost:5000/api'; // iOS simulator
  static const String physicalDeviceUrl =
      'http://192.168.1.100:5000/api'; // Physical device

  // Production
  static const String prodBaseUrl = 'https://your-production-url.com/api';

  // Current environment
  static const bool isProduction = false;

  // Get the appropriate base URL
  static String get baseUrl {
    if (isProduction) {
      return prodBaseUrl;
    }

    // For Android emulator, always use 10.0.2.2
    return androidEmulatorUrl;
  }
}
