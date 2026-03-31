import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/fees_due_controller.dart';
import '../models/fees_assignment_model.dart';
import '_fees_nav_tabs.dart';
import '_fees_shared.dart';

class FeesDueView extends StatelessWidget {
  const FeesDueView({super.key});

  FeesDueController get _c => Get.find<FeesDueController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Due Fees',
      body: Column(
        children: [
          const FeesNavTabs(activeRoute: AppRoutes.feesDue),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.overdueList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSummaryGrid(),
                      const SizedBox(height: 16),
                      _buildFilterBar(),
                      const SizedBox(height: 8),
                      _buildList(),
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

  Widget _buildSummaryGrid() {
    return Obx(() {
      final s = _c.summary.value;
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
        children: [
          fSummaryCard(
            label: 'Total Assigned',
            value: '₹ ${fmtAmt(s.totalAssigned)}',
            accent: const Color(0xFF4F46E5),
            icon: Icons.assignment_outlined,
          ),
          fSummaryCard(
            label: 'Discount',
            value: '₹ ${fmtAmt(s.totalDiscount)}',
            accent: const Color(0xFFD97706),
            icon: Icons.local_offer_outlined,
          ),
          fSummaryCard(
            label: 'Net Amount',
            value: '₹ ${fmtAmt(s.totalNet)}',
            accent: const Color(0xFF0F766E),
            icon: Icons.calculate_outlined,
          ),
          fSummaryCard(
            label: 'Collected',
            value: '₹ ${fmtAmt(s.totalPaid)}',
            accent: const Color(0xFF16A34A),
            icon: Icons.check_circle_outline,
          ),
          fSummaryCard(
            label: 'Total Due',
            value: '₹ ${fmtAmt(s.totalDue)}',
            accent: const Color(0xFFDC2626),
            icon: Icons.pending_outlined,
          ),
          fSummaryCard(
            label: 'Overdue Records',
            value: '${_c.overdueList.length}',
            accent: const Color(0xFF7C3AED),
            icon: Icons.warning_amber_outlined,
          ),
        ],
      );
    });
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: fCardDecoration(),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: fDropdown<int?>(
                  hint: 'All Years',
                  value: _c.filterYearId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Years')),
                    ..._c.academicYears.map((y) =>
                        DropdownMenuItem(
                            value: y.id, child: Text(y.title))),
                  ],
                  onChanged: (v) {
                    _c.filterYearId.value = v;
                    _c.applyFilter();
                  },
                ),
              ),
              const SizedBox(width: 10),
              fActionBtn(Icons.refresh, kFeesPrimary, _c.loadAll),
            ],
          )),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.overdueList.isEmpty) {
        return fEmptyState('No overdue fees found.',
            icon: Icons.check_circle_outline);
      }
      return Column(
        children: _c.overdueList
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DueCard(
                    assignment: a,
                    isOverdue: _c.isOverdue(a),
                  ),
                ))
            .toList(),
      );
    });
  }
}

// ── Due card ───────────────────────────────────────────────────────────────────

class _DueCard extends StatelessWidget {
  final FeesAssignment assignment;
  final bool isOverdue;

  const _DueCard({
    required this.assignment,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: fCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isOverdue ? kFeesRed : kFeesAmber,
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
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (isOverdue
                                    ? kFeesRed
                                    : kFeesAmber)
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            assignment.studentName.isNotEmpty
                                ? assignment.studentName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isOverdue
                                    ? kFeesRed
                                    : kFeesAmber),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignment.studentName.isNotEmpty
                                    ? assignment.studentName
                                    : 'Student #${assignment.student}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              if (assignment.admissionNo.isNotEmpty)
                                Text(
                                  assignment.admissionNo,
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(
                                          0xFF9CA3AF)),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹ ${fmtAmt(assignment.dueAmount)}',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kFeesRed,
                              ),
                            ),
                            Text(
                              'Due',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(Icons.receipt_outlined,
                            assignment.feesTypeName.isNotEmpty
                                ? assignment.feesTypeName
                                : 'Type #${assignment.feesType}',
                            const Color(0xFF0F766E)),
                        _chip(
                            Icons.event_outlined,
                            'Due: ${assignment.dueDate}',
                            isOverdue
                                ? kFeesRed
                                : const Color(0xFF6B7280)),
                        fStatusBadge(assignment.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7F7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: kFeesRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          _amt('Net',
                              fmtAmt(assignment.netAmount),
                              const Color(0xFF374151)),
                          _vertDiv(),
                          _amt('Paid',
                              fmtAmt(assignment.paidAmount),
                              kFeesGreen),
                          _vertDiv(),
                          _amt('Due',
                              fmtAmt(assignment.dueAmount),
                              kFeesRed),
                        ],
                      ),
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
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color)),
          ],
        ),
      );

  Widget _amt(String label, String value, Color color) =>
      Expanded(
        child: Column(
          children: [
            Text('₹ $value',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: const Color(0xFF9CA3AF))),
          ],
        ),
      );

  Widget _vertDiv() => Container(
        width: 1, height: 28, color: const Color(0xFFE5E7EB));
}
