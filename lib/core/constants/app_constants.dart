/// Central app constants.
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static const String kBaseUrl = 'https://app.eskoolia.com';

  // Secure storage keys (mirrors auth.ts)
  static const String kAccessTokenKey = 'school_erp_access_token';
  static const String kRefreshTokenKey = 'school_erp_refresh_token';

  // API paths (mirrors api-auth.ts)
  static const String kLoginPath = '/api/v1/auth/login/';
  static const String kRefreshPath = '/api/v1/auth/refresh/';
  static const String kLogoutPath = '/api/v1/auth/logout/';
}
