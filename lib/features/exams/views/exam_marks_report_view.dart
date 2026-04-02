import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/students/views/_student_shared.dart';
import '../controllers/exam_marks_report_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class ExamMarksReportView extends StatelessWidget {
  const ExamMarksReportView({super.key});

  ExamMarksReportController get _c => Get.find<ExamMarksReportController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Marks Register',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examMarksRegister),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CriteriaCard(c: _c),
                    const SizedBox(height: 14),
                    Obx(() {
                      if (_c.rows.isEmpty) return const SizedBox.shrink();
                      return _ReportCard(c: _c);
                    }),
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
  final ExamMarksReportController c;
  const _CriteriaCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Criteria',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827))),
          const SizedBox(height: 14),
          Obx(() => _LabeledDropdown<int?>(
                label: 'Exam *',
                value: c.selectedExamId.value,
                hint: 'Select Exam',
                items: c.examTypes
                    .map((t) =>
                        DropdownMenuItem(value: t.id, child: Text(t.title)))
                    .toList(),
                onChanged: (v) => c.selectedExamId.value = v,
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledDropdown<int?>(
                label: 'Class *',
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
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledDropdown<int?>(
                label: 'Subject *',
                value: c.selectedSubjectId.value,
                hint: 'Select Subject',
                items: c.subjects
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => c.selectedSubjectId.value = v,
              )),
          const SizedBox(height: 10),
          Obx(() => _LabeledDropdown<int?>(
                label: 'Section',
                value: c.selectedSectionId.value,
                hint: 'All Sections',
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Sections')),
                  ...c.filteredSections.map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name))),
                ],
                onChanged: (v) => c.selectedSectionId.value = v,
              )),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: c.isSearching.value ? null : c.search,
                  icon: c.isSearching.value
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded, size: 18),
                  label: Text(
                      c.isSearching.value ? 'Searching...' : 'Search',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              )),
          Obx(() {
            if (c.errorMsg.value.isNotEmpty) {
              return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _StatusBanner(message: c.errorMsg.value, isError: true));
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// ── Report Card ──────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final ExamMarksReportController c;
  const _ReportCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                '${c.rows.length} Result${c.rows.length == 1 ? '' : 's'}',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827)),
              )),
          const SizedBox(height: 14),
          Obx(() => Column(
                children: c.rows
                    .map((r) => _ReportRowCard(row: r, parts: c.parts))
                    .toList(),
              )),
        ],
      ),
    );
  }
}

class _ReportRowCard extends StatelessWidget {
  final MarksRegisterRow row;
  final List<ExamSetupInfo> parts;

  const _ReportRowCard({required this.row, required this.parts});

  @override
  Widget build(BuildContext context) {
    final initials = row.firstName.isNotEmpty
        ? row.firstName[0].toUpperCase() +
            (row.lastName.isNotEmpty ? row.lastName[0].toUpperCase() : '')
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: row.isAbsent
                        ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                        : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(initials,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.fullName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF111827))),
                    Text(
                        'Adm: ${row.admissionNo}'
                        '${row.rollNo.isNotEmpty ? ' · Roll: ${row.rollNo}' : ''}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              sBadge(
                row.isAbsent ? 'Absent' : 'Present',
                row.isAbsent
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Per-part marks
          ...parts.map((part) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${part.examTitle} (max ${part.examMark})',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF6B7280)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        row.partValue(part.id),
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: const Color(0xFF4F46E5)),
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16),
          // Totals row
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  label: 'Total',
                  value: row.totalMarks,
                  color: const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'GPA',
                  value: row.totalGpaPoint,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  label: 'Grade',
                  value: row.totalGpaGrade,
                  color: const Color(0xFFEA580C),
                ),
              ),
            ],
          ),
          if (row.teacherRemarks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.comment_outlined,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(row.teacherRemarks,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280),
                          fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      );
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel(label),
          const SizedBox(height: 6),
          sDropdown<T>(
            value: value,
            hint: hint,
            items: items,
            onChanged: onChanged,
          ),
        ],
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
          style: GoogleFonts.inter(fontSize: 13, color: color)),
    );
  }
}
