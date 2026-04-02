import 'package:dio/dio.dart';

/// Centralized backend error message extractor.
///
/// Django REST Framework can return errors in multiple formats:
///   - {"detail": "Not found."}
///   - {"message": "Validation failed."}
///   - {"error": "duplicate_entry"}
///   - {"non_field_errors": ["This field is required."]}
///   - {"field_name": ["Error for this field."]}
///   - ["Error string in a list"]
///   - "Plain string error"
///
/// This helper tries all known patterns and returns a clean,
/// user-facing message — never a raw stack trace.
class ApiError {
  ApiError._();

  /// Extract a human-readable error message from any exception.
  /// Always returns a non-empty string suitable for showing to the user.
  static String extract(dynamic exception, [String fallback = 'Something went wrong. Please try again.']) {
    if (exception is DioException) {
      return _fromDio(exception, fallback);
    }
    if (exception is Exception) {
      return exception.toString().replaceFirst('Exception: ', '');
    }
    return fallback;
  }

  static String _fromDio(DioException e, String fallback) {
    // No response — network/connection issue
    if (e.response == null) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your network.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Cannot reach server. Please check your connection.';
      }
      return e.message ?? fallback;
    }

    final data = e.response?.data;
    final status = e.response?.statusCode ?? 0;

    // Try to extract message from response body
    final msg = _extractFromBody(data);
    if (msg != null && msg.isNotEmpty) return msg;

    // Fallback to status-based messages
    if (status == 400) return 'Invalid data. Please check your input.';
    if (status == 401) return 'Session expired. Please login again.';
    if (status == 403) return 'You don\'t have permission for this action.';
    if (status == 404) return 'The requested resource was not found.';
    if (status == 409) return 'Conflict — this record may already exist.';
    if (status == 422) return 'Validation error. Please check your input.';
    if (status >= 500) return 'Server error ($status). Please try again later.';

    return fallback;
  }

  /// Try all known Django/DRF error response formats.
  static String? _extractFromBody(dynamic data) {
    if (data == null) return null;

    // Plain string response
    if (data is String && data.isNotEmpty) return data;

    // List of errors: ["error1", "error2"]
    if (data is List && data.isNotEmpty) {
      return data.map((e) => e.toString()).join('. ');
    }

    // Map response — try known keys first
    if (data is Map<String, dynamic>) {
      // Direct message keys (most common)
      for (final key in ['detail', 'message', 'error', 'msg']) {
        final val = data[key];
        if (val is String && val.isNotEmpty) return val;
        if (val is List && val.isNotEmpty) {
          return val.map((e) => e.toString()).join('. ');
        }
      }

      // non_field_errors (DRF validation)
      final nfe = data['non_field_errors'];
      if (nfe is List && nfe.isNotEmpty) {
        return nfe.map((e) => e.toString()).join('. ');
      }

      // Field-level errors: {"field_name": ["error msg"]}
      // Collect all field errors into a readable string
      final fieldErrors = <String>[];
      data.forEach((key, value) {
        if (key == 'status_code' || key == 'status') return;
        if (value is List && value.isNotEmpty) {
          final msgs = value.map((e) => e.toString()).join(', ');
          // Humanize field name: "first_name" → "First name"
          final fieldName = key
              .replaceAll('_', ' ')
              .replaceFirstMapped(
                  RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
          fieldErrors.add('$fieldName: $msgs');
        } else if (value is String && value.isNotEmpty) {
          final fieldName = key
              .replaceAll('_', ' ')
              .replaceFirstMapped(
                  RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
          fieldErrors.add('$fieldName: $value');
        }
      });
      if (fieldErrors.isNotEmpty) return fieldErrors.join('\n');
    }

    return null;
  }
}
