import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/fees_master_controller.dart';
import '../models/fees_assignment_model.dart';
import '_fees_nav_tabs.dart';
import '_fees_shared.dart';
import '../../../core/widgets/school_loader.dart';

class FeesMasterView extends StatelessWidget {
  const FeesMasterView({super.key});

  FeesMasterController get _c => Get.find<FeesMasterController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Fees Master',
      body: Column(
        children: [
          const FeesNavTabs(activeRoute: AppRoutes.feesMaster),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.assignments.isEmpty) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 16),
                      _buildFilters(context),
                      const SizedBox(height: 8),
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
        backgroundColor: kFeesPrimary,
        foregroundColor: Colors.white,
        onPressed: () {
          _c.startCreate();
          _showSheet(context, isEdit: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards() {
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
            label: 'Due',
            value: '₹ ${fmtAmt(s.totalDue)}',
            accent: const Color(0xFFDC2626),
            icon: Icons.pending_outlined,
          ),
          fSummaryCard(
            label: 'Records',
            value: '${s.count}',
            accent: const Color(0xFF7C3AED),
            icon: Icons.people_outline,
          ),
        ],
      );
    });
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: fCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 160,
                    child: fDropdown<int?>(
                      hint: 'All Years',
                      value: _c.filterYearId.value,
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Years')),
                        ..._c.academicYears.map((y) => DropdownMenuItem(
                            value: y.id, child: Text(y.title))),
                      ],
                      onChanged: (v) => _c.filterYearId.value = v,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: fDropdown<int?>(
                      hint: 'All Students',
                      value: _c.filterStudentId.value,
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Students')),
                        ...{
                          for (final a in _c.assignments)
                            a.student: a.studentName.isNotEmpty
                                ? a.studentName
                                : 'Student #${a.student}'
                        }.entries.map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value))),
                      ],
                      onChanged: (v) => _c.filterStudentId.value = v,
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: fDropdown<String?>(
                      hint: 'All Status',
                      value: _c.filterStatus.value,
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('All Status')),
                        DropdownMenuItem(
                            value: 'unpaid', child: Text('Unpaid')),
                        DropdownMenuItem(
                            value: 'partial', child: Text('Partial')),
                        DropdownMenuItem(
                            value: 'paid', child: Text('Paid')),
                      ],
                      onChanged: (v) => _c.filterStatus.value = v,
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: fDropdown<int?>(
                      hint: 'All Types',
                      value: _c.filterTypeId.value,
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Types')),
                        ...{
                          for (final a in _c.assignments)
                            a.feesType: a.feesTypeName.isNotEmpty
                                ? a.feesTypeName
                                : 'Type #${a.feesType}'
                        }.entries.map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value))),
                      ],
                      onChanged: (v) => _c.filterTypeId.value = v,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(() => fPrimaryBtn(
                      label: 'Apply Filter',
                      loading: _c.isLoading.value,
                      onPressed: _c.applyFilters,
                    )),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: _c.resetFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Reset',
                    style: GoogleFonts.inter(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      if (_c.assignments.isEmpty) {
        return fEmptyState(
            'No fee assignments found.\nTap + to assign fees.',
            icon: Icons.assignment_outlined);
      }
      return Column(
        children: _c.assignments
            .map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AssignmentCard(
                    assignment: a,
                    yearName: _c.yearName(a.academicYear),
                    onEdit: () {
                      _c.startEdit(a);
                      _showSheet(context, isEdit: true);
                    },
                    onDelete: () => fDeleteDialog(
                      context,
                      'Delete this fee assignment? This cannot be undone.',
                      () => _c.deleteAssignment(a.id),
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
      builder: (_) =>
          _AssignmentFormSheet(controller: _c, isEdit: isEdit),
    );
  }
}

// ── Assignment card ────────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final FeesAssignment assignment;
  final String yearName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AssignmentCard({
    required this.assignment,
    required this.yearName,
    required this.onEdit,
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
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _statusColor(assignment.status),
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
                                      color:
                                          const Color(0xFF9CA3AF)),
                                ),
                            ],
                          ),
                        ),
                        fStatusBadge(assignment.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Amount row
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _amtCol('Amount',
                              fmtAmt(assignment.amount),
                              const Color(0xFF374151)),
                          _divider(),
                          _amtCol('Discount',
                              fmtAmt(assignment.discountAmount),
                              kFeesAmber),
                          _divider(),
                          _amtCol(
                              'Net', fmtAmt(assignment.netAmount),
                              kFeesTeal),
                          _divider(),
                          _amtCol(
                              'Paid', fmtAmt(assignment.paidAmount),
                              kFeesGreen),
                          _divider(),
                          _amtCol(
                              'Due', fmtAmt(assignment.dueAmount),
                              assignment.dueAmount > 0
                                  ? kFeesRed
                                  : const Color(0xFF6B7280)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(Icons.receipt_outlined,
                            assignment.feesTypeName.isNotEmpty
                                ? assignment.feesTypeName
                                : 'Type #${assignment.feesType}',
                            const Color(0xFF0F766E)),
                        _chip(Icons.calendar_today_outlined,
                            'Due: ${assignment.dueDate}',
                            const Color(0xFF6366F1)),
                        _chip(Icons.school_outlined, yearName,
                            const Color(0xFF7C3AED)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        fActionBtn(Icons.edit_outlined,
                            kFeesPrimary, onEdit),
                        const SizedBox(width: 8),
                        fActionBtn(Icons.delete_outline,
                            kFeesRed, onDelete),
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

  Color _statusColor(String s) {
    switch (s) {
      case 'paid':
        return kFeesGreen;
      case 'partial':
        return kFeesAmber;
      default:
        return kFeesRed;
    }
  }

  Widget _amtCol(String label, String value, Color color) =>
      Expanded(
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 9, color: const Color(0xFF9CA3AF))),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1, height: 28, color: const Color(0xFFE5E7EB));

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
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color)),
          ],
        ),
      );
}

// ── Assignment form sheet ──────────────────────────────────────────────────────

class _AssignmentFormSheet extends StatelessWidget {
  final FeesMasterController controller;
  final bool isEdit;

  const _AssignmentFormSheet(
      {required this.controller, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            isEdit ? 'Edit Fee Assignment' : 'Assign Fee',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Year
          fLabel('Academic Year *'),
          Obx(() => fDropdown<int?>(
                hint: 'Select year',
                value: controller.formYearId.value,
                items: controller.academicYears
                    .map((y) => DropdownMenuItem(
                        value: y.id as int?, child: Text(y.title)))
                    .toList(),
                onChanged: (v) =>
                    controller.formYearId.value = v,
              )),
          const SizedBox(height: 14),

          // Student
          fLabel('Student *'),
          Obx(() => fDropdown<int?>(
                hint: 'Select student',
                value: controller.formStudentId.value,
                items: controller.students
                    .map((s) => DropdownMenuItem(
                        value: s.id as int?,
                        child: Text(s.displayLabel,
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) =>
                    controller.formStudentId.value = v,
              )),
          const SizedBox(height: 14),

          // Fee type
          fLabel('Fee Type *'),
          Obx(() => fDropdown<int?>(
                hint: 'Select fee type',
                value: controller.formTypeId.value,
                items: controller.types
                    .map((t) => DropdownMenuItem(
                        value: t.id as int?, child: Text(t.name)))
                    .toList(),
                onChanged: (v) =>
                    controller.formTypeId.value = v,
              )),
          const SizedBox(height: 14),

          // Due date
          fLabel('Due Date *'),
          fTextField(
            controller.dueDateCtrl,
            'YYYY-MM-DD',
            readOnly: true,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(
                        controller.dueDateCtrl.text) ??
                    DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                controller.dueDateCtrl.text =
                    picked.toIso8601String().split('T').first;
              }
            },
          ),
          const SizedBox(height: 14),

          // Amount
          fLabel('Amount *'),
          fTextField(
            controller.amountCtrl,
            '0.00',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            prefixText: '₹ ',
          ),
          const SizedBox(height: 14),

          // Discount
          fLabel('Discount Amount'),
          fTextField(
            controller.discountCtrl,
            '0.00',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            prefixText: '₹ ',
          ),
          const SizedBox(height: 20),

          Obx(() => fPrimaryBtn(
                label:
                    isEdit ? 'Update Assignment' : 'Assign Fee',
                loading: controller.isLoading.value,
                onPressed: controller.saveAssignment,
              )),
        ],
      ),
    );
  }
}
