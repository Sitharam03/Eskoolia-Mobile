import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/chart_of_accounts_controller.dart';
import '../models/finance_models.dart';
import '_finance_nav_tabs.dart';
import '_finance_shared.dart';

class ChartOfAccountsView extends StatelessWidget {
  const ChartOfAccountsView({super.key});

  ChartOfAccountsController get _c =>
      Get.find<ChartOfAccountsController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accounts',
      body: Column(
        children: [
          const FinanceNavTabs(
              activeRoute: AppRoutes.financeChartOfAccounts),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.accounts.isEmpty) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterBar(),
                      const SizedBox(height: 12),
                      _buildList(context),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kFinPrimary,
        foregroundColor: Colors.white,
        onPressed: () {
          _c.startCreate();
          _showSheet(context, isEdit: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: finCardDecoration(),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: finDropdown<String?>(
                  hint: 'All Types',
                  value: _c.filterType.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Types')),
                    for (final t in [
                      'asset',
                      'liability',
                      'equity',
                      'income',
                      'expense'
                    ])
                      DropdownMenuItem(
                        value: t,
                        child: Text(finTypeLabel(t)),
                      ),
                  ],
                  onChanged: (v) => _c.filterType.value = v,
                ),
              ),
              const SizedBox(width: 10),
              finActionBtn(Icons.refresh, kFinPrimary, _c.loadAll),
            ],
          )),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final list = _c.filtered;
      if (list.isEmpty) {
        return finEmptyState(
          'No accounts found.\nTap + to add one.',
          icon: Icons.account_tree_outlined,
        );
      }
      return Column(
        children: list
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AccountCard(
                    account: a,
                    onEdit: () {
                      _c.startEdit(a);
                      _showSheet(context, isEdit: true);
                    },
                    onDelete: () => finDeleteDialog(
                      context,
                      'Delete account "${a.code} – ${a.name}"? This cannot be undone.',
                      () => _c.delete(a.id),
                    ),
                  ),
                ))
            .toList(),
      );
    });
  }

  void _showSheet(BuildContext context, {required bool isEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AccountFormSheet(controller: _c, isEdit: isEdit),
    );
  }
}

// ── Account Card ──────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final ChartOfAccount account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AccountCard({
    required this.account,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = finTypeColor(account.accountType);
    final balVal = double.tryParse(account.balance) ?? 0.0;
    final balColor = balVal >= 0 ? kFinGreen : kFinRed;

    return Container(
      decoration: finCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Code chip + name + active
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            account.code,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            account.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        finActiveBadge(account.isActive),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Type + balance
                    Row(
                      children: [
                        finTypeBadge(account.accountType),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Balance',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: kFinGray),
                            ),
                            Text(
                              finFmtAmt(account.balance),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: balColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (account.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        account.description,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: kFinGray),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        finActionBtn(
                            Icons.edit_outlined, kFinPrimary, onEdit),
                        const SizedBox(width: 8),
                        finActionBtn(
                            Icons.delete_outline, kFinRed, onDelete),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Account Form Sheet ────────────────────────────────────────────────────────

class _AccountFormSheet extends StatelessWidget {
  final ChartOfAccountsController controller;
  final bool isEdit;

  const _AccountFormSheet(
      {required this.controller, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            finSheetHandle(),
            Text(
              isEdit ? 'Edit Account' : 'Add Account',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            finLabel('Account Code *'),
            finTextField(controller.codeCtrl, 'e.g. 1001'),
            const SizedBox(height: 14),

            finLabel('Account Name *'),
            finTextField(controller.nameCtrl, 'e.g. Cash in Hand'),
            const SizedBox(height: 14),

            finLabel('Account Type *'),
            Obx(() => finDropdown<String?>(
                  hint: 'Select type',
                  value: controller.formType.value,
                  items: [
                    for (final t in [
                      'asset',
                      'liability',
                      'equity',
                      'income',
                      'expense'
                    ])
                      DropdownMenuItem(
                          value: t, child: Text(finTypeLabel(t))),
                  ],
                  onChanged: (v) => controller.formType.value = v,
                )),
            const SizedBox(height: 14),

            finLabel('Description'),
            finTextField(
              controller.descCtrl,
              'Optional description',
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            Obx(() => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title:
                      Text('Active', style: GoogleFonts.inter(fontSize: 14)),
                  value: controller.formIsActive.value,
                  activeColor: kFinPrimary,
                  onChanged: (v) => controller.formIsActive.value = v,
                )),
            const SizedBox(height: 8),

            Obx(() => finPrimaryBtn(
                  label: isEdit ? 'Update Account' : 'Create Account',
                  loading: controller.isLoading.value,
                  onPressed: controller.save,
                )),
          ],
        ),
      ),
    );
  }
}
