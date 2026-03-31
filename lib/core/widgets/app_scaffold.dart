import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/app_routes.dart';
import '../services/storage_service.dart';

/// Scaffold wrapper for all module pages.
/// Back button and device back → navigate to dashboard.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  Future<void> _logout() async {
    await StorageService.to.clearAuthTokens();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.offAllNamed(AppRoutes.dashboard);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FBFF),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF374151), size: 20),
            onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
            splashRadius: 20,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: const Color(0xFF1F2937),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF6B7280)),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE5E7EB)),
          ),
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
