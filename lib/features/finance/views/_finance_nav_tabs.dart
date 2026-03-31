import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '_finance_shared.dart';

class _TabDef {
  final String label;
  final String route;
  const _TabDef(this.label, this.route);
}

class FinanceNavTabs extends StatefulWidget {
  final String activeRoute;
  const FinanceNavTabs({super.key, required this.activeRoute});

  static const _tabs = <_TabDef>[
    _TabDef('Chart of Accounts', AppRoutes.financeChartOfAccounts),
    _TabDef('Bank Accounts', AppRoutes.financeBankAccounts),
    _TabDef('Ledger', AppRoutes.financeLedger),
    _TabDef('Fund Transfer', AppRoutes.financeFundTransfer),
  ];

  @override
  State<FinanceNavTabs> createState() => _FinanceNavTabsState();
}

class _FinanceNavTabsState extends State<FinanceNavTabs> {
  final _scrollCtrl = ScrollController();
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(
        FinanceNavTabs._tabs.length, (_) => GlobalKey());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _jumpToActive());
  }

  void _jumpToActive() {
    final idx = FinanceNavTabs._tabs
        .indexWhere((t) => t.route == widget.activeRoute);
    if (idx < 0) return;
    final ctx = _keys[idx].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        alignment: 0.5, duration: Duration.zero);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0;
                i < FinanceNavTabs._tabs.length;
                i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _FinTab(
                key: _keys[i],
                label: FinanceNavTabs._tabs[i].label,
                route: FinanceNavTabs._tabs[i].route,
                isActive: FinanceNavTabs._tabs[i].route ==
                    widget.activeRoute,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinTab extends StatelessWidget {
  final String label;
  final String route;
  final bool isActive;

  const _FinTab({
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
          color: isActive ? kFinPrimary : const Color(0xFFF3F4F6),
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
