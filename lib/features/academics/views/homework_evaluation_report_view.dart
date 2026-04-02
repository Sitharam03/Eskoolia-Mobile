import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/homework_controller.dart';
import '../models/academics_models.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';
import '../../../core/widgets/school_loader.dart';

class HomeworkEvaluationReportView extends GetView<HomeworkController> {
  const HomeworkEvaluationReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Evaluation Report',
      body: Column(
        children: [
          const AcademicsNavTabs(
              activeRoute: AppRoutes.academicsHomeworkEvalReport),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _FilterCard(controller: controller),
                  const SizedBox(height: 16),
                  _ReportTable(controller: controller),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter card ───────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final HomeworkController controller;
  const _FilterCard({required this.controller});

  HomeworkController get c => controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              aSectionHeader('Filter Report'),

              aDropdown<String>(
                value: c.reportClassId.value.isEmpty
                    ? null
                    : c.reportClassId.value,
                label: 'Class',
                items: [
                  _none('All classes'),
                  ...c.classes.map((cl) => _dd(cl.id.toString(), cl.name)),
                ],
                onChanged: (v) {
                  c.reportClassId.value = v ?? '';
                  c.reportSectionId.value = '';
                },
              ),
              const SizedBox(height: 12),

              aDropdown<String>(
                value: c.reportSectionId.value.isEmpty
                    ? null
                    : c.reportSectionId.value,
                label: 'Section',
                items: [
                  _none('All sections'),
                  ...c.reportSections.map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) => c.reportSectionId.value = v ?? '',
              ),
              const SizedBox(height: 12),

              aDropdown<String>(
                value: c.reportSubjectId.value.isEmpty
                    ? null
                    : c.reportSubjectId.value,
                label: 'Subject',
                items: [
                  _none('All subjects'),
                  ...c.subjects.map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) => c.reportSubjectId.value = v ?? '',
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: aPrimaryBtn('Load Report', () => c.loadReport()),
              ),
            ],
          )),
    );
  }

  static DropdownMenuItem<String> _none(String label) =>
      DropdownMenuItem(
          value: '',
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF6B7280))));

  static DropdownMenuItem<String> _dd(String v, String label) =>
      DropdownMenuItem(
          value: v,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF111827))));
}

// ── Report table ──────────────────────────────────────────────────────────────

class _ReportTable extends StatelessWidget {
  final HomeworkController controller;
  const _ReportTable({required this.controller});

  HomeworkController get c => controller;

  String _subjectName(int id) {
    final s = c.subjects.firstWhereOrNull((s) => s.id == id);
    return s?.name ?? '#$id';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isReportLoading.value) {
        return const SchoolLoader();
      }
      if (c.reportError.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
          ),
          child: Text(c.reportError.value,
              style:
                  GoogleFonts.inter(color: const Color(0xFFDC2626), fontSize: 14)),
        );
      }
      if (c.reportRows.isEmpty) {
        return aEmptyState(
            'No report data.\nSelect filters and click Load Report.');
      }

      return Container(
        decoration: aCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F3FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(children: [
                const Icon(Icons.analytics_rounded,
                    color: Color(0xFF4F46E5), size: 18),
                const SizedBox(width: 8),
                Text('Report (${c.reportRows.length} entries)',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF4F46E5))),
              ]),
            ),

            // Scrollable data table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF9FAFB)),
                headingTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: const Color(0xFF374151)),
                dataTextStyle: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF374151)),
                border: TableBorder.all(
                    color: const Color(0xFFE5E7EB), width: 1),
                columns: const [
                  DataColumn(label: Text('Homework\nDate')),
                  DataColumn(label: Text('Submission\nDate')),
                  DataColumn(label: Text('Evaluation\nDate')),
                  DataColumn(label: Text('Subject')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Incomplete')),
                  DataColumn(label: Text('Pending')),
                  DataColumn(label: Text('Description')),
                ],
                rows: c.reportRows.map((row) {
                  final hw = row['homework'] as Homework;
                  final completed = row['completed'] as int;
                  final incomplete = row['incomplete'] as int;
                  final pending = row['pending'] as int;
                  return DataRow(cells: [
                    DataCell(Text(hw.homeworkDate)),
                    DataCell(Text(hw.submissionDate)),
                    DataCell(Text(hw.evaluationDate ?? '-')),
                    DataCell(Text(_subjectName(hw.subjectId))),
                    DataCell(aBadge('$completed', const Color(0xFF16A34A))),
                    DataCell(aBadge('$incomplete', const Color(0xFFDC2626))),
                    DataCell(aBadge('$pending', const Color(0xFFD97706))),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          hw.description.length > 80
                              ? '${hw.description.substring(0, 80)}...'
                              : hw.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
