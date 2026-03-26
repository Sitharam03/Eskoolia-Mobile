import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_drawer.dart';
import '../services/storage_service.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

/// A reusable Scaffold wrapper that provides the AppBar and the AppDrawer (Sidebar).
/// Use this to wrap the main content of every major module page.
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1F2937),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4B5563)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF6B7280)),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
