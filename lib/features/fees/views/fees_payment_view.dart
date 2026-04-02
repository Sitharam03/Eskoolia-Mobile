import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/fees_payment_controller.dart';
import '../models/fees_assignment_model.dart';
import '../models/fees_payment_model.dart';
import '_fees_nav_tabs.dart';
import '_fees_shared.dart';
import '../../../core/widgets/school_loader.dart';

class FeesPaymentView extends StatelessWidget {
  const FeesPaymentView({super.key});

  FeesPaymentController get _c => Get.find<FeesPaymentController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Fees Collection',
      body: Column(
        children: [
          const FeesNavTabs(activeRoute: AppRoutes.feesPayments),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.allAssignments.isEmpty) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormCard(context),
                      const SizedBox(height: 16),
                      _buildPaymentsSection(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Add Payment Form ─────────────────────────────────────────────────────────

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: fCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Payment',
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),

          // Assignment dropdown
          fLabel('Assignment *'),
          Obx(() => fDropdown<int?>(
                hint: 'Select assignment',
                value: _c.formAssignmentId.value,
                items: [
                  const DropdownMenuItem(
                      value: null,
                      child: Text('Select assignment')),
                  ..._c.allAssignments
                      .where((a) => a.status != 'paid')
                      .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(
                              _c.assignmentLabel(a),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                ],
                onChanged: (v) => _c.onAssignmentChanged(v),
              )),

          // Assignment detail (status + discount) shown when selected
          Obx(() {
            final a = _c.selectedAssignment;
            if (a == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Status: ',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280)),
                    ),
                    fStatusBadge(a.status),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Discount: ₹${fmtAmt(a.discountAmount)}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B7280)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ₹${fmtAmt(a.dueAmount)}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kFeesRed),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),

          // Amount + Method row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Amount *'),
                    fTextField(
                      _c.amountCtrl,
                      '0.00',
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      prefixText: '₹ ',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Method *'),
                    Obx(() => fDropdown<String>(
                          hint: 'Method',
                          value: _c.formMethod.value,
                          items: FeesPaymentController.methodOptions
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                        FeesPaymentController
                                            .methodLabels[m]!),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) _c.formMethod.value = v;
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Paid At
          fLabel('Payment Date *'),
          fTextField(
            _c.paidAtCtrl,
            'YYYY-MM-DD',
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.tryParse(_c.paidAtCtrl.text) ??
                        DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                _c.paidAtCtrl.text =
                    picked.toIso8601String().split('T').first;
              }
            },
          ),
          const SizedBox(height: 12),

          // Transaction Ref + Note row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Transaction Ref'),
                    fTextField(
                        _c.transRefCtrl, 'Optional reference'),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fLabel('Note'),
                    fTextField(_c.noteCtrl, 'Optional note'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() => fPrimaryBtn(
                label: 'Save',
                loading: _c.isLoading.value,
                color: kFeesTeal,
                onPressed: _c.recordPayment,
              )),
        ],
      ),
    );
  }

  // ── Payments list ────────────────────────────────────────────────────────────

  Widget _buildPaymentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Payments',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            fActionBtn(Icons.refresh, kFeesPrimary, _c.refreshHistory),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (_c.isLoading.value && _c.payments.isEmpty) {
            return const SchoolLoader();
          }
          if (_c.payments.isEmpty) {
            return fEmptyState('No payments recorded yet.',
                icon: Icons.payments_outlined);
          }
          return Column(
            children: _c.payments
                .map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PaymentCard(
                        payment: p,
                        onReceipt: () =>
                            _showReceipt(context, p.id),
                        onDelete: () => fDeleteDialog(
                          context,
                          'Delete this payment record?',
                          () => _c.deletePayment(p.id),
                        ),
                      ),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  void _showReceipt(BuildContext context, int paymentId) async {
    await _c.loadReceipt(paymentId);
    if (_c.receipt.value != null) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (_) => _ReceiptDialog(receipt: _c.receipt.value!),
      );
    }
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

String _formatDateTime(String iso) {
  if (iso.isEmpty) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final mon = dt.month.toString().padLeft(2, '0');
    final yr = dt.year;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$day/$mon/$yr  $h:$min $ampm';
  } catch (_) {
    // fallback: strip T
    return iso.replaceFirst('T', '  ').split('.').first.split('+').first;
  }
}

// ── Payment card ───────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final FeesPayment payment;
  final VoidCallback onReceipt;
  final VoidCallback onDelete;

  const _PaymentCard({
    required this.payment,
    required this.onReceipt,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: fCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: kFeesGreen,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: student name + amount ────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.studentName.isNotEmpty
                                    ? payment.studentName
                                    : 'Student #${payment.student}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (payment.admissionNo.isNotEmpty)
                                Text(
                                  payment.admissionNo,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              const SizedBox(height: 2),
                              _chip(
                                Icons.assignment_outlined,
                                'Assignment #${payment.assignment}',
                                kFeesPrimary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kFeesGreen.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '₹ ${fmtAmt(payment.amountPaid)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: kFeesGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ── Row 2: chips ─────────────────────────────────────────
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        fMethodBadge(payment.method),
                        if (payment.feesTypeName.isNotEmpty)
                          _chip(Icons.label_outline,
                              payment.feesTypeName,
                              kFeesTeal),
                        _chip(
                          Icons.access_time_outlined,
                          _formatDateTime(payment.paidAt),
                          const Color(0xFF6366F1),
                        ),
                        if (payment.transactionReference.isNotEmpty)
                          _chip(Icons.tag,
                              payment.transactionReference,
                              const Color(0xFF374151)),
                        if (payment.note.isNotEmpty)
                          _chip(Icons.notes_outlined, payment.note,
                              const Color(0xFF9CA3AF)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ── Row 3: actions ───────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _actionBtn(
                          icon: Icons.receipt_long_outlined,
                          label: 'Receipt',
                          color: kFeesPrimary,
                          onTap: onReceipt,
                        ),
                        const SizedBox(width: 8),
                        _actionBtn(
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          color: kFeesRed,
                          onTap: onDelete,
                        ),
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

  Widget _chip(IconData icon, String label, Color color) =>
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      );

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Receipt dialog ─────────────────────────────────────────────────────────────

class _ReceiptDialog extends StatelessWidget {
  final FeesReceipt receipt;

  const _ReceiptDialog({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Payment Receipt',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 20),
            _row('Receipt #', '#${receipt.paymentId}'),
            _row('Student', receipt.studentName),
            if (receipt.admissionNo.isNotEmpty)
              _row('Admission No', receipt.admissionNo),
            const Divider(height: 20),
            _row('Fee Type', receipt.feesTypeName),
            _row('Due Date', receipt.dueDate),
            const Divider(height: 20),
            _row('Total Amount', '₹ ${fmtAmt(receipt.amount)}'),
            if (receipt.discountAmount > 0)
              _row('Discount',
                  '- ₹ ${fmtAmt(receipt.discountAmount)}',
                  valueColor: kFeesAmber),
            _row('Net Amount', '₹ ${fmtAmt(receipt.netAmount)}'),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: kFeesGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount Paid',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kFeesGreen)),
                  Text('₹ ${fmtAmt(receipt.amountPaid)}',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kFeesGreen)),
                ],
              ),
            ),
            _row('Balance Due', '₹ ${fmtAmt(receipt.dueAmount)}',
                valueColor:
                    receipt.dueAmount > 0 ? kFeesRed : kFeesGreen),
            const Divider(height: 20),
            _row('Method', receipt.method.toUpperCase()),
            _row('Paid At', _formatDateTime(receipt.paidAt)),
            if (receipt.transactionReference.isNotEmpty)
              _row('Reference', receipt.transactionReference),
            if (receipt.recordedBy != null)
              _row('Recorded By', receipt.recordedBy!),
            if (receipt.note.isNotEmpty)
              _row('Note', receipt.note),
            const SizedBox(height: 12),
            fStatusBadge(receipt.status),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280))),
            ),
            Expanded(
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor ??
                          const Color(0xFF111827))),
            ),
          ],
        ),
      );
}
