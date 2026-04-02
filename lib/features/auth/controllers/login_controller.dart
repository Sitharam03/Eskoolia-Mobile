import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_error.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';
import '../repositories/auth_repository.dart';

/// GetX controller for the login screen.
/// Mirrors the [submit] function from login/page.tsx:
///   - POSTs credentials → stores tokens → navigates to dashboard.
class LoginController extends GetxController {
  final _repo = AuthRepository.instance;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => obscurePassword.toggle();

  /// Validates form fields locally before hitting the network.
  bool _validate() {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      errorMessage.value = 'Username is required.';
      return false;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Password is required.';
      return false;
    }
    return true;
  }

  /// Calls the login endpoint, stores JWT tokens, then navigates to dashboard.
  Future<void> submit() async {
    if (!_validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final tokens = await _repo.login(
        usernameController.text.trim(),
        passwordController.text,
      );

      await StorageService.to.setAuthTokens(
        accessToken: tokens.access,
        refreshToken: tokens.refresh,
      );

      // Navigate to dashboard, clearing the back stack
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      errorMessage.value = ApiError.extract(e, 'Login failed');
    } finally {
      isLoading.value = false;
    }
  }
}
