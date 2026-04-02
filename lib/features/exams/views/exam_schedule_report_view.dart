import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/exam_schedule_report_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class ExamScheduleReportView extends StatelessWidget {
  const ExamScheduleReportView({super.key});

  ExamScheduleReportController get _c =>
      Get.find<ExamScheduleReportController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examScheduleReport),
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
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _ScheduleListCard(c: _c),
                          );
                        }
                        if (!_c.isSearching.value && _c.errorMsg.value.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: sEmptyState('No schedule records found',
                                Icons.calendar_today_rounded),
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
  final ExamScheduleReportController c;
  const _SearchCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Filter Schedule'),
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
                onChanged: (v) => c.selectedSectionId.value = v,
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

class _ScheduleListCard extends StatelessWidget {
  final ExamScheduleReportController c;
  const _ScheduleListCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          sectionHeader('Schedule'),
          Obx(() => Text('${c.rows.length} records',
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF6B7280)))),
        ]),
        const SizedBox(height: 12),
        ...c.rows.map((r) => _ScheduleRow(row: r)),
      ]),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final ScheduleReportRow row;
  const _ScheduleRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(row.subjectName,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
          ),
          sBadge(row.examDate, const Color(0xFF4F46E5)),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 12, runSpacing: 4, children: [
          _Detail(
              icon: Icons.access_time_rounded,
              text: '${row.startTime} – ${row.endTime}'),
          _Detail(
              icon: Icons.class_rounded,
              text: '${row.className}  ${row.sectionName}'),
          if (row.teacherName.isNotEmpty)
            _Detail(icon: Icons.person_rounded, text: row.teacherName),
          if (row.room.isNotEmpty)
            _Detail(icon: Icons.room_rounded, text: row.room),
        ]),
      ]),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Detail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
      const SizedBox(width: 4),
      Text(text,
          style: GoogleFonts.inter(
              fontSize: 12, color: const Color(0xFF6B7280))),
    ]);
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
