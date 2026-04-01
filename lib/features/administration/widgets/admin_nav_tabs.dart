import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal scrollable tab chip navigation bar used across Administration views.
class AdminNavTabs extends StatefulWidget {
  final List<AdminTabItem> tabs;
  const AdminNavTabs({super.key, required this.tabs});

  @override
  State<AdminNavTabs> createState() => _AdminNavTabsState();
}

class _AdminNavTabsState extends State<AdminNavTabs> {
  final _scrollController = ScrollController();
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.tabs.length, (_) => GlobalKey());
    // Jump instantly after layout — no animation so user never sees scroll-from-start
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToActive());
  }

  void _jumpToActive() {
    final activeIndex = widget.tabs.indexWhere((t) => t.isActive);
    if (activeIndex < 0) return;
    final ctx = _keys[activeIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: Duration.zero, // instant — no visible slide-from-start
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF5F3FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < widget.tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _NavChip(key: _keys[i], tab: widget.tabs[i]),
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
  const _NavChip({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!tab.isActive) Get.offNamed(tab.route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: tab.isActive
              ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF7C3AED)])
              : null,
          color: tab.isActive ? null : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: tab.isActive
              ? null
              : Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.12)),
          boxShadow: tab.isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          tab.label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: tab.isActive ? FontWeight.w600 : FontWeight.w500,
            color: tab.isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
