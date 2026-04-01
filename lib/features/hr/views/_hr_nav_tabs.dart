import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HrNavTabs extends StatefulWidget {
  final String activeRoute;
  const HrNavTabs({super.key, required this.activeRoute});

  @override
  State<HrNavTabs> createState() => _HrNavTabsState();
}

class _HrNavTabsState extends State<HrNavTabs> {
  static const _tabs = [
    _Tab('Departments', '/hr/departments'),
    _Tab('Designations', '/hr/designations'),
    _Tab('Add Staff', '/hr/staff'),
    _Tab('Directory', '/hr/staff-directory'),
    _Tab('Leave Types', '/hr/leave-types'),
    _Tab('Leave Define', '/hr/leave-defines'),
    _Tab('Leave Requests', '/hr/leave-requests'),
    _Tab('Attendance', '/hr/staff-attendance'),
    _Tab('Payroll', '/hr/payroll'),
  ];

  final _scroll = ScrollController();
  final _keys = List.generate(9, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idx = _tabs.indexWhere((t) => t.route == widget.activeRoute);
      if (idx >= 0) {
        final ctx = _keys[idx].currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.5, duration: Duration.zero);
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
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
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < _tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            GestureDetector(
              key: _keys[i],
              onTap: () { if (_tabs[i].route != widget.activeRoute) Get.offNamed(_tabs[i].route); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  gradient: _tabs[i].route == widget.activeRoute
                      ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF7C3AED)])
                      : null,
                  color: _tabs[i].route == widget.activeRoute ? null : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: _tabs[i].route == widget.activeRoute
                      ? null
                      : Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.12)),
                  boxShadow: _tabs[i].route == widget.activeRoute
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
                child: Text(_tabs[i].label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: _tabs[i].route == widget.activeRoute ? FontWeight.w600 : FontWeight.w500,
                    color: _tabs[i].route == widget.activeRoute ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Tab {
  final String label;
  final String route;
  const _Tab(this.label, this.route);
}
