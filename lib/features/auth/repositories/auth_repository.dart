import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_model.dart';

/// Handles all authentication API calls.
/// Uses [ApiClient.rawDio] (no auth interceptor) to avoid circular refresh loops.
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  /// POST /api/v1/auth/login/
  /// Returns [TokenResponse] on success.
  /// Throws [DioException] on network error or non-2xx from backend.
  Future<TokenResponse> login(String username, String password) async {
    final response = await ApiClient.rawDio.post(
      AppConstants.kLoginPath,
      data: LoginRequest(username: username, password: password).toJson(),
    );
    return TokenResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/refresh/
  Future<TokenResponse> refresh(String refreshToken) async {
    final response = await ApiClient.rawDio.post(
      AppConstants.kRefreshPath,
      data: {'refresh': refreshToken},
    );
    return TokenResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/logout/
  Future<void> logout(String refreshToken) async {
    await ApiClient.rawDio.post(
      AppConstants.kLogoutPath,
      data: {'refresh': refreshToken},
    );
  }
}
