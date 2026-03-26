/// Central app constants.
/// For physical device testing change [kBaseUrl] to your machine's LAN IP,
/// e.g. 'http://192.168.1.5:8000'
class AppConstants {
  AppConstants._();

  static const String kBaseUrl = 'http://127.0.0.1:8000';

  // Secure storage keys (mirrors auth.ts)
  static const String kAccessTokenKey = 'school_erp_access_token';
  static const String kRefreshTokenKey = 'school_erp_refresh_token';

  // API paths (mirrors api-auth.ts)
  static const String kLoginPath = '/api/v1/auth/login/';
  static const String kRefreshPath = '/api/v1/auth/refresh/';
  static const String kLogoutPath = '/api/v1/auth/logout/';
}
