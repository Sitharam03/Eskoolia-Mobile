// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:eskoolia_mobile/core/constants/app_constants.dart';
import 'package:eskoolia_mobile/core/routes/app_routes.dart';
import 'package:eskoolia_mobile/core/services/storage_service.dart';

/// Singleton Dio client with JWT Bearer token injection and automatic
/// 401 → refresh → retry logic.
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
///
/// FIX: Uses a Completer queue so that when multiple 401s arrive
/// concurrently, only ONE refresh is attempted. All other requests
/// wait for that refresh to complete, then retry with the new token
/// instead of immediately redirecting to login.
class AuthInterceptor extends Interceptor {
  /// If non-null, a refresh is in progress — other 401s wait on this.
  static Completer<String?>? _refreshCompleter;

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

    // ── Another refresh already in-flight? Wait for it. ──
    if (_refreshCompleter != null) {
      final newToken = await _refreshCompleter!.future;
      if (newToken != null && newToken.isNotEmpty) {
        // Retry original request with the refreshed token
        return _retry(err, newToken, handler);
      }
      // Refresh failed — but don't redirect here, the first caller handles it
      return handler.reject(err);
    }

    // ── We are the first 401 — perform the refresh. ──
    _refreshCompleter = Completer<String?>();

    try {
      final storage = StorageService.to;
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken.isEmpty) {
        _refreshCompleter!.complete(null);
        _refreshCompleter = null;
        await _redirectToLogin();
        return handler.reject(err);
      }

      final refreshRes = await ApiClient.rawDio.post<Map<String, dynamic>>(
        AppConstants.kRefreshPath,
        data: {'refresh': refreshToken},
      );

      final newAccess = refreshRes.data?['access'] as String?;
      // Some backends also return a new refresh token
      final newRefresh =
          (refreshRes.data?['refresh'] as String?) ?? refreshToken;

      if (newAccess == null || newAccess.isEmpty) {
        _refreshCompleter!.complete(null);
        _refreshCompleter = null;
        await _redirectToLogin();
        return handler.reject(err);
      }

      // Store the new tokens
      await storage.setAuthTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Unblock all waiting 401 callers with the new token
      _refreshCompleter!.complete(newAccess);
      _refreshCompleter = null;

      // Retry the original request
      return _retry(err, newAccess, handler);
    } catch (_) {
      // Refresh itself failed — unblock waiters + redirect
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(null);
      }
      _refreshCompleter = null;
      await _redirectToLogin();
      return handler.reject(err);
    }
  }

  /// Retry the original request with a fresh access token.
  /// Uses [ApiClient.rawDio] to avoid re-entering this interceptor.
  Future<void> _retry(
    DioException err,
    String newToken,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final opts = Options(
        method: err.requestOptions.method,
        headers: {
          ...err.requestOptions.headers,
          'Authorization': 'Bearer $newToken',
        },
      );
      final retried = await ApiClient.rawDio.request<dynamic>(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: opts,
      );
      return handler.resolve(retried);
    } catch (e) {
      // If retry itself fails, pass the error through (don't logout)
      return handler.reject(err);
    }
  }

  Future<void> _redirectToLogin() async {
    await StorageService.to.clearAuthTokens();
    if (Get.currentRoute != AppRoutes.login &&
        Get.currentRoute != AppRoutes.splash) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
