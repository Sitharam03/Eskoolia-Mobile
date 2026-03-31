import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/fund_transfer_controller.dart';
import '../models/finance_models.dart';
import '_finance_nav_tabs.dart';
import '_finance_shared.dart';

class FundTransferView extends StatelessWidget {
  const FundTransferView({super.key});

  FundTransferController get _c => Get.find<FundTransferController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Accounts',
      body: Column(
        children: [
          const FinanceNavTabs(activeRoute: AppRoutes.financeFundTransfer),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.transfers.isEmpty) {
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
          _showSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final list = _c.transfers;
      if (list.isEmpty) {
        return finEmptyState(
          'No fund transfers found.\nTap + to create one.',
          icon: Icons.swap_horiz_outlined,
        );
      }
      return Column(
        children: list
            .map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransferCard(
                    transfer: t,
                    fromName: _c.bankName(t.fromBankId),
                    toName: _c.bankName(t.toBankId),
                    onDelete: () => finDeleteDialog(
                      context,
                      'Delete this fund transfer? Bank balances will not be reversed automatically.',
                      () => _c.delete(t.id),
                    ),
                  ),
                ))
            .toList(),
      );
    });
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TransferFormSheet(controller: _c),
    );
  }
}

// ── Transfer Card ─────────────────────────────────────────────────────────────

class _TransferCard extends StatelessWidget {
  final FundTransfer transfer;
  final String fromName;
  final String toName;
  final VoidCallback onDelete;

  const _TransferCard({
    required this.transfer,
    required this.fromName,
    required this.toName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: finCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    // Amount + date
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            finFmtAmt(transfer.amount),
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: kFinPrimary,
                            ),
                          ),
                        ),
                        finChip(
                          Icons.calendar_today_outlined,
                          finFmtDate(transfer.transferDate),
                          kFinGray,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Transfer route: From → To
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          // From bank
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FROM',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: kFinDebit,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fromName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Arrow
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kFinPrimary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  size: 14, color: kFinPrimary),
                            ),
                          ),
                          // To bank
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'TO',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: kFinCredit,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  toName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Reference + note
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (transfer.referenceNo.isNotEmpty)
                          finChip(Icons.tag_outlined,
                              transfer.referenceNo, kFinBlue),
                        if (transfer.note.isNotEmpty)
                          finChip(Icons.notes_outlined,
                              transfer.note, kFinGray),
                      ],
                    ),
                    const SizedBox(height: 10),
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

// ── Transfer Form Sheet ───────────────────────────────────────────────────────

class _TransferFormSheet extends StatelessWidget {
  final FundTransferController controller;

  const _TransferFormSheet({required this.controller});

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
              'New Fund Transfer',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            finLabel('From Bank *'),
            Obx(() => finDropdown<int?>(
                  hint: 'Select source bank',
                  value: controller.formFromBankId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Select...')),
                    ...controller.bankAccounts
                        .where((b) => b.isActive)
                        .map((b) => DropdownMenuItem(
                              value: b.id,
                              child: Text(
                                '${b.name}  (${finFmtAmt(b.currentBalance)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                  ],
                  onChanged: (v) => controller.formFromBankId.value = v,
                )),
            const SizedBox(height: 14),

            finLabel('To Bank *'),
            Obx(() => finDropdown<int?>(
                  hint: 'Select destination bank',
                  value: controller.formToBankId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('Select...')),
                    ...controller.bankAccounts
                        .where((b) =>
                            b.isActive &&
                            b.id != controller.formFromBankId.value)
                        .map((b) => DropdownMenuItem(
                              value: b.id,
                              child: Text(b.name,
                                  overflow: TextOverflow.ellipsis),
                            )),
                  ],
                  onChanged: (v) => controller.formToBankId.value = v,
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

            finLabel('Transfer Date *'),
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
            finTextField(
                controller.referenceCtrl, 'Optional reference'),
            const SizedBox(height: 14),

            finLabel('Note'),
            finTextField(
              controller.noteCtrl,
              'Optional note',
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            Obx(() => finPrimaryBtn(
                  label: 'Transfer Funds',
                  loading: controller.isLoading.value,
                  onPressed: controller.save,
                  icon: Icons.swap_horiz,
                )),
          ],
        ),
      ),
    );
  }
}
