import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:eskoolia_mobile/core/constants/app_constants.dart';

/// Wraps [FlutterSecureStorage] to persist JWT tokens securely.
/// Mirrors the localStorage logic in auth.ts.
class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Read the stored access token (empty string if absent).
  Future<String> getAccessToken() async {
    return await _storage.read(key: AppConstants.kAccessTokenKey) ?? '';
  }

  /// Read the stored refresh token (empty string if absent).
  Future<String> getRefreshToken() async {
    return await _storage.read(key: AppConstants.kRefreshTokenKey) ?? '';
  }

  /// Persist both tokens after a successful login or refresh.
  Future<void> setAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: AppConstants.kAccessTokenKey,
      value: accessToken,
    );
    await _storage.write(
      key: AppConstants.kRefreshTokenKey,
      value: refreshToken,
    );
  }

  /// Delete both tokens on logout or refresh failure.
  Future<void> clearAuthTokens() async {
    await _storage.delete(key: AppConstants.kAccessTokenKey);
    await _storage.delete(key: AppConstants.kRefreshTokenKey);
  }

  /// Returns true when an access token is currently stored.
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token.isNotEmpty;
  }
}
