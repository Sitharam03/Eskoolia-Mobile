import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal scrollable tab chip navigation bar used across Administration views.
class AdminNavTabs extends StatelessWidget {
  final List<AdminTabItem> tabs;
  const AdminNavTabs({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _NavChip(tab: tabs[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminTabItem {
  final String label;
  final String route;
  final bool isActive;
  const AdminTabItem(
      {required this.label, required this.route, this.isActive = false});
}

class _NavChip extends StatelessWidget {
  final AdminTabItem tab;
  const _NavChip({required this.tab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!tab.isActive) Get.offNamed(tab.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              tab.isActive ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tab.label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: tab.isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
