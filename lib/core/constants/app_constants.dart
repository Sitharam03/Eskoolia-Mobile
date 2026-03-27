/// Central app constants.
/// For physical device testing change [kBaseUrl] to your machine's LAN IP,
/// e.g. 'http://192.168.1.5:8000'
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static String get kBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      // Android Emulator uses 10.0.2.2 to reach the host computer's 127.0.0.1
      // if (Platform.isAndroid) return 'http://10.0.2.2:8000';
      // If testing on a REAL physical phone, comment the line above and uncomment the line below:
      if (Platform.isAndroid) return 'http://192.168.0.124:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000'; // iOS Simulator or Web Default
  }

  // Secure storage keys (mirrors auth.ts)
  static const String kAccessTokenKey = 'school_erp_access_token';
  static const String kRefreshTokenKey = 'school_erp_refresh_token';

  // API paths (mirrors api-auth.ts)
  static const String kLoginPath = '/api/v1/auth/login/';
  static const String kRefreshPath = '/api/v1/auth/refresh/';
  static const String kLogoutPath = '/api/v1/auth/logout/';
}
