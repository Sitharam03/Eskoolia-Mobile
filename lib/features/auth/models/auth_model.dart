/// Request payload sent to POST /api/v1/auth/login/
class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

/// Response from login and token refresh endpoints.
/// Mirrors { access: string; refresh: string } from login/page.tsx
class TokenResponse {
  final String access;
  final String refresh;

  const TokenResponse({required this.access, required this.refresh});

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );
}
