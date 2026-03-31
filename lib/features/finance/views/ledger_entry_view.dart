import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/ledger_entry_controller.dart';
import '../models/finance_models.dart';
import '_finance_nav_tabs.dart';
import '_finance_shared.dart';

class LedgerEntryView extends StatelessWidget {
  const LedgerEntryView({super.key});

  LedgerEntryController get _c => Get.find<LedgerEntryController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accounts',
      body: Column(
        children: [
          const FinanceNavTabs(activeRoute: AppRoutes.financeLedger),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.entries.isEmpty) {
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
                      _buildSummaryBar(),
                      const SizedBox(height: 12),
                      _buildFilterBar(context),
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
          _showAddSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Obx(() {
      final s = _c.summary.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: finStatCard(
                  label: 'Total Debit',
                  value: finFmtAmt(s?.totalDebit ?? '0.00'),
                  color: kFinDebit,
                  icon: Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: finStatCard(
                  label: 'Total Credit',
                  value: finFmtAmt(s?.totalCredit ?? '0.00'),
                  color: kFinCredit,
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: finStatCard(
                  label: 'Net Balance',
                  value: finFmtAmt(s?.netBalance ?? '0.00'),
                  color: kFinPrimary,
                  icon: Icons.account_balance_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTrialBalanceSheet(
                      Get.context!), // safe: always has context
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kFinBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: kFinBlue.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.table_chart_outlined,
                                size: 16, color: kFinBlue),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Trial Balance',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kFinBlue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to View',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kFinBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: finCardDecoration(),
      child: Obx(() => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: finDropdown<String?>(
                      hint: 'All Types',
                      value: _c.filterType.value,
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('All Types')),
                        DropdownMenuItem(
                            value: 'debit', child: Text('Debit')),
                        DropdownMenuItem(
                            value: 'credit', child: Text('Credit')),
                      ],
                      onChanged: (v) => _c.filterType.value = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  finActionBtn(Icons.refresh, kFinPrimary, _c.loadAll),
                ],
              ),
              const SizedBox(height: 10),
              finDropdown<int?>(
                hint: 'All Accounts',
                value: _c.filterAccountId.value,
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Accounts')),
                  ..._c.accounts.map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Text('${a.code} – ${a.name}',
                            overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (v) => _c.filterAccountId.value = v,
              ),
            ],
          )),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final list = _c.filtered;
      if (list.isEmpty) {
        return finEmptyState(
          'No ledger entries found.\nTap + to add one.',
          icon: Icons.receipt_long_outlined,
        );
      }
      return Column(
        children: list
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EntryCard(
                    entry: e,
                    accountLabel: _c.accountLabel(e.accountId),
                    onDelete: () => finDeleteDialog(
                      context,
                      'Delete this ledger entry? This cannot be undone.',
                      () => _c.delete(e.id),
                    ),
                  ),
                ))
            .toList(),
      );
    });
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LedgerFormSheet(controller: _c),
    );
  }

  void _showTrialBalanceSheet(BuildContext context) {
    _c.loadTrialBalance();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TrialBalanceSheet(controller: _c),
    );
  }
}

// ── Entry Card ─────────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final LedgerEntry entry;
  final String accountLabel;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.accountLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = entry.entryType == 'debit';
    final color = isDebit ? kFinDebit : kFinCredit;

    return Container(
      decoration: finCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: account + amount badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            accountLabel,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        finAmtBadge(entry.amount, isDebit: isDebit),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Meta chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        finEntryBadge(entry.entryType),
                        finChip(Icons.calendar_today_outlined,
                            finFmtDate(entry.entryDate), kFinGray),
                        if (entry.referenceNo.isNotEmpty)
                          finChip(Icons.tag_outlined,
                              entry.referenceNo, kFinBlue),
                      ],
                    ),
                    if (entry.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.description,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: kFinGray),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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

// ── Ledger Form Sheet ─────────────────────────────────────────────────────────

class _LedgerFormSheet extends StatelessWidget {
  final LedgerEntryController controller;

  const _LedgerFormSheet({required this.controller});

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
              'Add Ledger Entry',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            finLabel('Academic Year (optional)'),
            Obx(() => finDropdown<int?>(
                  hint: 'Select year',
                  value: controller.formYearId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('None')),
                    ...controller.academicYears.map((y) =>
                        DropdownMenuItem(value: y.id, child: Text(y.title))),
                  ],
                  onChanged: (v) => controller.formYearId.value = v,
                )),
            const SizedBox(height: 14),

            finLabel('Account *'),
            Obx(() => finDropdown<int?>(
                  hint: 'Select account',
                  value: controller.formAccountId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Select...')),
                    ...controller.accounts.map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text('${a.code} – ${a.name}',
                              overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (v) => controller.formAccountId.value = v,
                )),
            const SizedBox(height: 14),

            finLabel('Entry Type *'),
            Obx(() => finDropdown<String?>(
                  hint: 'Select type',
                  value: controller.formType.value,
                  items: const [
                    DropdownMenuItem(value: 'debit', child: Text('Debit')),
                    DropdownMenuItem(
                        value: 'credit', child: Text('Credit')),
                  ],
                  onChanged: (v) => controller.formType.value = v,
                )),
            const SizedBox(height: 14),

            finLabel('Amount *'),
            finTextField(
              controller.amountCtrl,
              '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 14),

            finLabel('Entry Date *'),
            Obx(() => finDateTile(
                  label: 'Select date',
                  date: controller.formDate.value,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.formDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) controller.formDate.value = picked;
                  },
                )),
            const SizedBox(height: 14),

            finLabel('Reference No'),
            finTextField(controller.referenceCtrl, 'Optional reference'),
            const SizedBox(height: 14),

            finLabel('Description'),
            finTextField(
              controller.descCtrl,
              'Optional description',
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            Obx(() => finPrimaryBtn(
                  label: 'Add Entry',
                  loading: controller.isLoading.value,
                  onPressed: controller.save,
                  icon: Icons.add,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Trial Balance Sheet ───────────────────────────────────────────────────────

class _TrialBalanceSheet extends StatelessWidget {
  final LedgerEntryController controller;

  const _TrialBalanceSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (fixed)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                finSheetHandle(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Trial Balance',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Summary of all accounts with debit/credit totals',
                  style:
                      GoogleFonts.inter(fontSize: 12, color: kFinGray),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Scrollable body
          Flexible(
            child: Obx(() {
              if (controller.trialBalanceLoading.value) {
                return const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final tb = controller.trialBalance.value;
              if (tb == null || tb.accounts.isEmpty) {
                return finEmptyState(
                  'No trial balance data available.',
                  icon: Icons.table_chart_outlined,
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    // Account rows
                    ...tb.accounts.map((row) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _TrialBalanceCard(row: row),
                        )),

                    // Totals summary
                    const Divider(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kFinPrimary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: kFinPrimary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          _totalRow('Total Debit', tb.totalDebit,
                              kFinDebit),
                          const SizedBox(height: 8),
                          _totalRow('Total Credit', tb.totalCredit,
                              kFinCredit),
                          const Divider(height: 16),
                          _totalRow(
                            'Difference',
                            tb.difference,
                            (double.tryParse(tb.difference) ?? 0).abs() <
                                    0.01
                                ? kFinGreen
                                : kFinRed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151)),
          ),
        ),
        Text(
          finFmtAmt(value),
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

// ── Trial Balance Card ────────────────────────────────────────────────────────

class _TrialBalanceCard extends StatelessWidget {
  final TrialBalanceRow row;
  const _TrialBalanceCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final typeColor = finTypeColor(row.accountType);
    final balVal = double.tryParse(row.balance) ?? 0.0;
    final balColor = balVal >= 0 ? kFinGreen : kFinRed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: finCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code + name + type badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  row.accountCode,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  row.accountName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              finTypeBadge(row.accountType),
            ],
          ),
          const SizedBox(height: 10),
          // Debit / Credit / Balance
          Row(
            children: [
              Expanded(
                child: _amtCol('Debit', row.debit, kFinDebit),
              ),
              Expanded(
                child: _amtCol('Credit', row.credit, kFinCredit),
              ),
              Expanded(
                child: _amtCol('Balance', row.balance, balColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amtCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10,
                color: kFinGray,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          finFmtAmt(value),
          style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
