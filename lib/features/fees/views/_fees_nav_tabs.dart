import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';

class _TabDef {
  final String label;
  final String route;
  const _TabDef(this.label, this.route);
}

class FeesNavTabs extends StatefulWidget {
  final String activeRoute;
  const FeesNavTabs({super.key, required this.activeRoute});

  static const _tabs = <_TabDef>[
    _TabDef('Fees Groups', AppRoutes.feesGroups),
    _TabDef('Fees Types', AppRoutes.feesTypes),
    _TabDef('Fees Master', AppRoutes.feesMaster),
    _TabDef('Collection', AppRoutes.feesPayments),
    _TabDef('Due Fees', AppRoutes.feesDue),
    _TabDef('Carry Forward', AppRoutes.feesCarryForward),
  ];

  @override
  State<FeesNavTabs> createState() => _FeesNavTabsState();
}

class _FeesNavTabsState extends State<FeesNavTabs> {
  final _scrollController = ScrollController();
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(FeesNavTabs._tabs.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToActive());
  }

  void _jumpToActive() {
    final idx = FeesNavTabs._tabs
        .indexWhere((t) => t.route == widget.activeRoute);
    if (idx < 0) return;
    final ctx = _keys[idx].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: Duration.zero,
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
            for (int i = 0; i < FeesNavTabs._tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _FeesChip(
                key: _keys[i],
                label: FeesNavTabs._tabs[i].label,
                route: FeesNavTabs._tabs[i].route,
                isActive:
                    FeesNavTabs._tabs[i].route == widget.activeRoute,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeesChip extends StatelessWidget {
  final String label;
  final String route;
  final bool isActive;

  const _FeesChip({
    super.key,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isActive) Get.offNamed(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF7C3AED)])
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(22),
          border: isActive
              ? null
              : Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.12)),
          boxShadow: isActive
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
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
