// ignore_for_file: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:eskoolia_mobile/core/constants/app_constants.dart';
import 'package:eskoolia_mobile/core/routes/app_routes.dart';
import 'package:eskoolia_mobile/core/services/storage_service.dart';

/// Singleton Dio client with JWT Bearer token injection and automatic
/// 401 → refresh → retry logic.
///
/// Mirrors [apiRequestWithRefresh] from api-auth.ts:
///   1. Read access token → inject Authorization header.
///   2. On 401, call /api/v1/auth/refresh/ with stored refresh token.
///   3. On refresh success → update storage → retry original request.
///   4. On refresh failure → clear storage → navigate to /login.
class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(AuthInterceptor());

  /// Authenticated Dio instance — use for all protected API calls.
  static Dio get dio => _dio;

  /// Bare Dio (no auth interceptor) — used for login and refresh calls only.
  static final Dio rawDio = Dio(
    BaseOptions(
      baseUrl: AppConstants.kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}

/// JWT interceptor attached to [ApiClient.dio].
class AuthInterceptor extends Interceptor {
  static bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.to.getAccessToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      await _redirectToLogin();
      return handler.reject(err);
    }

    _isRefreshing = true;
    try {
      final storage = StorageService.to;
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken.isEmpty) {
        await _redirectToLogin();
        return handler.reject(err);
      }

      final refreshRes = await ApiClient.rawDio.post<Map<String, dynamic>>(
        AppConstants.kRefreshPath,
        data: {'refresh': refreshToken},
      );

      final newToken = refreshRes.data?['access'] as String?;
      if (newToken == null || newToken.isEmpty) {
        await _redirectToLogin();
        return handler.reject(err);
      }

      await storage.setAuthTokens(
        accessToken: newToken,
        refreshToken: refreshToken,
      );

      // Retry original request with new token
      final opts = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken';
      final retried = await ApiClient.dio.fetch<dynamic>(opts);
      return handler.resolve(retried);
    } on DioException catch (_) {
      await _redirectToLogin();
      return handler.reject(err);
    } catch (_) {
      await _redirectToLogin();
      return handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _redirectToLogin() async {
    await StorageService.to.clearAuthTokens();
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
