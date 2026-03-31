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
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _tabs[i].route == widget.activeRoute ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_tabs[i].label,
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: _tabs[i].route == widget.activeRoute ? Colors.white : const Color(0xFF6B7280))),
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
