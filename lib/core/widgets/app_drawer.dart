import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/app_routes.dart';
import '../services/storage_service.dart';

class _DrawerLogo extends StatelessWidget {
  const _DrawerLogo();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/eSkoolia_logo.jpeg',
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _logout() async {
    await StorageService.to.clearAuthTokens();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  const _DrawerLogo(),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'eSkoolia',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'School Management',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),

            // Info tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded,
                        color: Color(0xFF0EA5E9), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap any module card on the dashboard to navigate.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 22),
              title: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
