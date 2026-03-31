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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4F46E5)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
