import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/exam_report_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class ExamStudentReportView extends StatelessWidget {
  const ExamStudentReportView({super.key});

  ExamStudentReportController get _c =>
      Get.find<ExamStudentReportController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examStudentReport),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: _c.search,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    children: [
                      _SearchCard(c: _c),
                      Obx(() {
                        if (_c.errorMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ErrorBanner(msg: _c.errorMsg.value),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.rows.isNotEmpty) {
                          return Column(children: [
                            const SizedBox(height: 16),
                            _SummaryCard(c: _c),
                            const SizedBox(height: 12),
                            _SubjectListCard(c: _c),
                          ]);
                        }
                        if (!_c.isSearching.value && _c.errorMsg.value.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: sEmptyState(
                                'No report found', Icons.assignment_outlined),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
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
}

class _SearchCard extends StatelessWidget {
  final ExamStudentReportController c;
  const _SearchCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Search Student Report'),
        const SizedBox(height: 16),
        Obx(() => Column(children: [
              sFieldLabel('Exam'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedExamId.value,
                hint: 'Select Exam',
                items: c.examTypes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.title)))
                    .toList(),
                onChanged: (v) => c.selectedExamId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Class (Optional)'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedClassId.value,
                hint: 'All Classes',
                items: c.classes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) {
                  c.selectedClassId.value = v;
                  c.selectedSectionId.value = null;
                  c.selectedStudentId.value = null;
                },
              ),
              const SizedBox(height: 12),
              sFieldLabel('Section (Optional)'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedSectionId.value,
                hint: 'All Sections',
                items: c.filteredSections
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) {
                  c.selectedSectionId.value = v;
                  c.selectedStudentId.value = null;
                },
              ),
              const SizedBox(height: 12),
              sFieldLabel('Student'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedStudentId.value,
                hint: 'Select Student',
                items: c.filteredStudents
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.displayLabel,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => c.selectedStudentId.value = v,
              ),
            ])),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
                onPressed: c.isSearching.value ? null : c.search,
                icon: c.isSearching.value
                    ? sSavingIndicator()
                    : const Icon(Icons.search_rounded, size: 18),
                label: Text(c.isSearching.value ? 'Searching…' : 'Search',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )),
        ),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ExamStudentReportController c;
  const _SummaryCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (c.studentName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(c.studentName,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
          ),
        Row(children: [
          Expanded(
              child: _StatTile(
                  label: 'Total Marks',
                  value: c.totalMarks,
                  color: const Color(0xFF4F46E5))),
          const SizedBox(width: 12),
          Expanded(
              child: _StatTile(
                  label: 'Avg GPA',
                  value: c.averageGpa,
                  color: const Color(0xFF059669))),
          const SizedBox(width: 12),
          Expanded(
              child: _StatTile(
                  label: 'Grade',
                  value: c.overallGrade.isNotEmpty ? c.overallGrade : '-',
                  color: const Color(0xFFEA580C))),
        ]),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Column(children: [
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: const Color(0xFF6B7280))),
      ]),
    );
  }
}

class _SubjectListCard extends StatelessWidget {
  final ExamStudentReportController c;
  const _SubjectListCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Subject Results'),
        const SizedBox(height: 12),
        ...c.rows.map((r) => _SubjectRow(row: r)),
      ]),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  final StudentReportRow row;
  const _SubjectRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final color =
        row.isAbsent ? const Color(0xFFDC2626) : const Color(0xFF059669);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row.subjectName,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827))),
            if (row.remarks.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(row.remarks,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
            ],
          ]),
        ),
        if (row.isAbsent)
          sBadge('Absent', const Color(0xFFDC2626))
        else
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(row.totalMarks,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Row(children: [
              sBadge(row.grade, const Color(0xFF4F46E5)),
              const SizedBox(width: 6),
              Text('GPA: ${row.gpa}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
            ]),
          ]),
      ]),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: Color(0xFFDC2626), size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFFDC2626)))),
      ]),
    );
  }
}
