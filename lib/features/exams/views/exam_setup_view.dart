import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/students/views/_student_shared.dart';
import '../controllers/exam_setup_controller.dart';
import '_exam_nav_tabs.dart';

class ExamSetupView extends StatelessWidget {
  const ExamSetupView({super.key});

  ExamSetupController get _c => Get.find<ExamSetupController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Exam Setup',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examSetup),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5)));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CriteriaCard(c: _c),
                    const SizedBox(height: 14),
                    _MarkDistributionCard(c: _c),
                    const SizedBox(height: 14),
                    _SubmitCard(c: _c),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Criteria Card ────────────────────────────────────────────────────────────

class _CriteriaCard extends StatelessWidget {
  final ExamSetupController c;
  const _CriteriaCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exam Criteria',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
          const SizedBox(height: 14),
          Obx(() => _LabeledField(
                label: 'Exam Term *',
                child: sDropdown<int?>(
                  value: c.selectedExamTermId.value,
                  hint: 'Select Exam Term',
                  items: c.examTypes
                      .map((t) => DropdownMenuItem(value: t.id, child: Text(t.title)))
                      .toList(),
                  onChanged: (v) => c.selectedExamTermId.value = v,
                ),
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledField(
                label: 'Class *',
                child: sDropdown<int?>(
                  value: c.selectedClassId.value,
                  hint: 'Select Class',
                  items: c.classes
                      .map((cl) =>
                          DropdownMenuItem(value: cl.id, child: Text(cl.name)))
                      .toList(),
                  onChanged: (v) {
                    c.selectedClassId.value = v;
                    c.selectedSectionId.value = null;
                  },
                ),
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledField(
                label: 'Section *',
                child: sDropdown<int?>(
                  value: c.selectedSectionId.value,
                  hint: 'Select Section',
                  items: c.filteredSections
                      .map((s) =>
                          DropdownMenuItem(value: s.id, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => c.selectedSectionId.value = v,
                ),
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledField(
                label: 'Subject *',
                child: sDropdown<int?>(
                  value: c.selectedSubjectId.value,
                  hint: 'Select Subject',
                  items: c.subjects
                      .map((s) =>
                          DropdownMenuItem(value: s.id, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) => c.selectedSubjectId.value = v,
                ),
              )),
          const SizedBox(height: 10),
          Obx(() {
            final total = c.totalMark;
            return _InfoChip(
                label: 'Total Distribution: ${total.toStringAsFixed(2)}');
          }),
        ],
      ),
    );
  }
}

// ── Mark Distribution Card ───────────────────────────────────────────────────

class _MarkDistributionCard extends StatelessWidget {
  final ExamSetupController c;
  const _MarkDistributionCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mark Distributions',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827))),
              ElevatedButton.icon(
                onPressed: c.addRow,
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text('Exam Title',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6B7280)))),
                      Expanded(
                          flex: 2,
                          child: Text('Exam Mark',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6B7280)))),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(c.rows.length, (i) => _RowItem(
                        index: i,
                        c: c,
                      )),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text('Total',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: const Color(0xFF111827)))),
                      Expanded(
                          flex: 2,
                          child: Text(
                            c.totalMark.toStringAsFixed(2),
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: const Color(0xFF4F46E5)),
                          )),
                      const SizedBox(width: 40),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class _RowItem extends StatefulWidget {
  final int index;
  final ExamSetupController c;
  const _RowItem({required this.index, required this.c});

  @override
  State<_RowItem> createState() => _RowItemState();
}

class _RowItemState extends State<_RowItem> {
  late TextEditingController _titleCtrl;
  late TextEditingController _markCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
        text: widget.c.rows[widget.index].examTitle);
    _markCtrl = TextEditingController(
        text: widget.c.rows[widget.index].examMark);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _markCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: sTextField(
              controller: _titleCtrl,
              hint: 'Exam title',
              onChanged: (v) => widget.c.updateRowTitle(widget.index, v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: sTextField(
              controller: _markCtrl,
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => widget.c.updateRowMark(widget.index, v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded,
                color: Color(0xFFDC2626), size: 20),
            onPressed: () => widget.c.removeRow(widget.index),
          ),
        ],
      ),
    );
  }
}

// ── Submit Card ──────────────────────────────────────────────────────────────

class _SubmitCard extends StatelessWidget {
  final ExamSetupController c;
  const _SubmitCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isSaving.value ? null : c.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: c.isSaving.value
                      ? sSavingIndicator()
                      : Text('Add Mark Distribution',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              if (c.errorMsg.value.isNotEmpty) ...[
                const SizedBox(height: 10),
                _StatusBanner(
                    message: c.errorMsg.value, isError: true),
              ],
              if (c.successMsg.value.isNotEmpty) ...[
                const SizedBox(height: 10),
                _StatusBanner(
                    message: c.successMsg.value, isError: false),
              ],
            ],
          )),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel(label),
          const SizedBox(height: 6),
          child,
        ],
      );
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4F46E5))),
      );
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? const Color(0xFFDC2626) : const Color(0xFF059669);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(message,
          style:
              GoogleFonts.inter(fontSize: 13, color: color)),
    );
  }
}
