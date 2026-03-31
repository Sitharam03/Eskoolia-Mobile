import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/bank_account_controller.dart';
import '../models/finance_models.dart';
import '_finance_nav_tabs.dart';
import '_finance_shared.dart';

class BankAccountView extends StatelessWidget {
  const BankAccountView({super.key});

  BankAccountController get _c => Get.find<BankAccountController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accounts',
      body: Column(
        children: [
          const FinanceNavTabs(activeRoute: AppRoutes.financeBankAccounts),
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
          _showFormSheet(context, isEdit: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final list = _c.accounts;
      if (list.isEmpty) {
        return finEmptyState(
          'No bank accounts found.\nTap + to add one.',
          icon: Icons.account_balance_outlined,
        );
      }
      return Column(
        children: list
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BankCard(
                    account: a,
                    onStatement: () {
                      _c.openStatementFor(a.id);
                      _showStatementSheet(context, a);
                    },
                    onEdit: () {
                      _c.startEdit(a);
                      _showFormSheet(context, isEdit: true);
                    },
                    onDelete: () => finDeleteDialog(
                      context,
                      'Delete bank account "${a.name}"? This cannot be undone.',
                      () => _c.delete(a.id),
                    ),
                  ),
                ))
            .toList(),
      );
    });
  }

  void _showFormSheet(BuildContext context, {required bool isEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _BankFormSheet(controller: _c, isEdit: isEdit),
    );
  }

  void _showStatementSheet(BuildContext context, BankAccount bank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _StatementSheet(controller: _c, bank: bank),
    );
  }
}

// ── Bank Card ─────────────────────────────────────────────────────────────────

class _BankCard extends StatelessWidget {
  final BankAccount account;
  final VoidCallback onStatement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BankCard({
    required this.account,
    required this.onStatement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bal = double.tryParse(account.currentBalance) ?? 0.0;
    final balColor = bal >= 0 ? kFinGreen : kFinRed;

    return Container(
      decoration: finCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent bar
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: kFinPrimary,
                borderRadius: BorderRadius.only(
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
                    // Name + active badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            account.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        finActiveBadge(account.isActive),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bank name + account number
                    Row(
                      children: [
                        finChip(Icons.account_balance_outlined,
                            account.bankName, kFinBlue),
                        const SizedBox(width: 6),
                        finChip(Icons.numbers_outlined,
                            account.accountNumber, kFinGray),
                      ],
                    ),
                    if (account.branch.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      finChip(Icons.location_on_outlined,
                          account.branch, kFinAmber),
                    ],
                    const SizedBox(height: 12),
                    // Balance
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: balColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: balColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              size: 16, color: balColor),
                          const SizedBox(width: 8),
                          Text(
                            'Current Balance',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: kFinGray),
                          ),
                          const Spacer(),
                          Text(
                            finFmtAmt(account.currentBalance),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: balColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onStatement,
                            icon: const Icon(Icons.receipt_long_outlined,
                                size: 15),
                            label: Text('Statement',
                                style: GoogleFonts.inter(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kFinPrimary,
                              side: BorderSide(
                                  color: kFinPrimary.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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

// ── Bank Form Sheet ───────────────────────────────────────────────────────────

class _BankFormSheet extends StatelessWidget {
  final BankAccountController controller;
  final bool isEdit;

  const _BankFormSheet(
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
              isEdit ? 'Edit Bank Account' : 'Add Bank Account',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            finLabel('Account Name *'),
            finTextField(
                controller.nameCtrl, 'e.g. Main Operating Account'),
            const SizedBox(height: 14),

            finLabel('Bank Name *'),
            finTextField(controller.bankNameCtrl, 'e.g. State Bank'),
            const SizedBox(height: 14),

            finLabel('Account Number *'),
            finTextField(
              controller.accountNumberCtrl,
              'e.g. 1234567890',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),

            finLabel('Branch'),
            finTextField(
                controller.branchCtrl, 'e.g. Main Branch (optional)'),
            const SizedBox(height: 14),

            finLabel('Opening Balance'),
            finTextField(
              controller.balanceCtrl,
              '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
                  label: isEdit
                      ? 'Update Bank Account'
                      : 'Create Bank Account',
                  loading: controller.isLoading.value,
                  onPressed: controller.save,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Statement Sheet ───────────────────────────────────────────────────────────

class _StatementSheet extends StatelessWidget {
  final BankAccountController controller;
  final BankAccount bank;

  const _StatementSheet(
      {required this.controller, required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          finSheetHandle(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Statement – ${bank.name}',
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            bank.bankName,
            style:
                GoogleFonts.inter(fontSize: 13, color: kFinGray),
          ),
          const SizedBox(height: 20),

          // Date range filters
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    finLabel('From Date'),
                    Obx(() => finDateTile(
                          label: 'Select start',
                          date: controller.stmtStartDate.value,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: controller.stmtStartDate.value ??
                                  DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              controller.stmtStartDate.value = picked;
                            }
                          },
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    finLabel('To Date'),
                    Obx(() => finDateTile(
                          label: 'Select end',
                          date: controller.stmtEndDate.value,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: controller.stmtEndDate.value ??
                                  DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              controller.stmtEndDate.value = picked;
                            }
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Obx(() => finPrimaryBtn(
                label: 'Load Statement',
                loading: controller.statementLoading.value,
                onPressed: controller.loadStatement,
                icon: Icons.receipt_long_outlined,
              )),
          const SizedBox(height: 20),

          // Statement result
          Flexible(
            child: SingleChildScrollView(
              child: Obx(() {
                if (controller.statementLoading.value) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final stmt = controller.statement.value;
                if (stmt == null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: finEmptyState(
                      'Select a date range and tap\n"Load Statement" to view.',
                      icon: Icons.receipt_long_outlined,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      _stmtRow('Incoming (Transfers In)',
                          stmt.incomingTotal, kFinCredit,
                          icon: Icons.arrow_downward),
                      const SizedBox(height: 10),
                      _stmtRow('Outgoing (Transfers Out)',
                          stmt.outgoingTotal, kFinDebit,
                          icon: Icons.arrow_upward),
                      const Divider(height: 24),
                      _stmtRow('Net Movement', stmt.netMovement,
                          (double.tryParse(stmt.netMovement) ?? 0) >= 0
                              ? kFinGreen
                              : kFinRed,
                          icon: Icons.swap_vert,
                          large: true),
                      const SizedBox(height: 10),
                      _stmtRow(
                          'Current Balance', stmt.currentBalance, kFinPrimary,
                          icon: Icons.account_balance_wallet_outlined,
                          large: true),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stmtRow(String label, String value, Color color,
      {required IconData icon, bool large = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: large ? 13 : 12,
                fontWeight:
                    large ? FontWeight.w600 : FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Text(
            finFmtAmt(value),
            style: GoogleFonts.inter(
              fontSize: large ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
