import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/exam_attendance_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';

class ExamAttendanceReportView extends StatelessWidget {
  const ExamAttendanceReportView({super.key});

  ExamAttendanceReportController get _c =>
      Get.find<ExamAttendanceReportController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examAttendanceReport),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
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
                            _ReportListCard(c: _c),
                          ]);
                        }
                        if (!_c.isSearching.value && _c.errorMsg.value.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: sEmptyState(
                                'No attendance records found',
                                Icons.event_busy_rounded),
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
  final ExamAttendanceReportController c;
  const _SearchCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Search Report'),
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
              sFieldLabel('Class'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedClassId.value,
                hint: 'Select Class',
                items: c.classes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) {
                  c.selectedClassId.value = v;
                  c.selectedSectionId.value = null;
                },
              ),
              const SizedBox(height: 12),
              sFieldLabel('Section'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedSectionId.value,
                hint: 'Select Section',
                items: c.filteredSections
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => c.selectedSectionId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Subject'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedSubjectId.value,
                hint: 'Select Subject',
                items: c.subjects
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => c.selectedSubjectId.value = v,
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
  final ExamAttendanceReportController c;
  const _SummaryCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Expanded(
            child: _StatTile(
                label: 'Total',
                value: c.rows.length.toString(),
                color: const Color(0xFF4F46E5))),
        const SizedBox(width: 12),
        Expanded(
            child: _StatTile(
                label: 'Present',
                value: c.presentCount.toString(),
                color: const Color(0xFF059669))),
        const SizedBox(width: 12),
        Expanded(
            child: _StatTile(
                label: 'Absent',
                value: c.absentCount.toString(),
                color: const Color(0xFFDC2626))),
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
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF6B7280))),
      ]),
    );
  }
}

class _ReportListCard extends StatelessWidget {
  final ExamAttendanceReportController c;
  const _ReportListCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Records'),
        const SizedBox(height: 12),
        ...c.rows.map((r) => _ReportRow(row: r)),
      ]),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final AttendanceReportRow row;
  const _ReportRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final color =
        row.isPresent ? const Color(0xFF059669) : const Color(0xFFDC2626);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row.fullName,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('Adm: ${row.admissionNo}  •  Roll: ${row.rollNo}',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF6B7280))),
          ]),
        ),
        sBadge(row.attendanceType, color),
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
