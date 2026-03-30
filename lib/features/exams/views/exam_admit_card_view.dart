import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/exam_admit_card_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';

class ExamAdmitCardView extends StatelessWidget {
  const ExamAdmitCardView({super.key});

  ExamAdmitCardController get _c => Get.find<ExamAdmitCardController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examAdmitCard),
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
                            child: _StatusBanner(msg: _c.errorMsg.value, isError: true),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.successMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _StatusBanner(msg: _c.successMsg.value, isError: false),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.students.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _StudentListCard(c: _c),
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
  final ExamAdmitCardController c;
  const _SearchCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Search Students'),
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

class _StudentListCard extends StatelessWidget {
  final ExamAdmitCardController c;
  const _StudentListCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          sectionHeader('Students'),
          Obx(() => Row(children: [
                Text('Select All',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF6B7280))),
                Checkbox(
                  value: c.allSelected,
                  onChanged: (v) => c.toggleAll(v ?? false),
                  activeColor: const Color(0xFF4F46E5),
                ),
              ])),
        ]),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: c.students.map((s) => _StudentRow(student: s, c: c)).toList(),
            )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
                onPressed: c.isGenerating.value ? null : c.generate,
                icon: c.isGenerating.value
                    ? sSavingIndicator()
                    : const Icon(Icons.print_rounded, size: 18),
                label: Text(
                    c.isGenerating.value ? 'Generating…' : 'Generate Admit Cards',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
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

class _StudentRow extends StatelessWidget {
  final AdmitCardStudent student;
  final ExamAdmitCardController c;
  const _StudentRow({required this.student, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final checked = c.selectedMap[student.studentRecordId] ?? false;
      final isOld = c.oldIds.contains(student.studentRecordId);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: checked
              ? const Color(0xFF4F46E5).withValues(alpha: 0.05)
              : const Color(0xFFF9FAFB),
          border: Border.all(
              color: checked
                  ? const Color(0xFF4F46E5).withValues(alpha: 0.3)
                  : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Checkbox(
            value: checked,
            onChanged: (v) =>
                c.toggleStudent(student.studentRecordId, v ?? false),
            activeColor: const Color(0xFF4F46E5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.fullName,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827))),
              const SizedBox(height: 2),
              Text('Admission: ${student.admissionNo}  •  Roll: ${student.rollNo}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
            ]),
          ),
          if (isOld) sBadge('Generated', const Color(0xFF059669)),
        ]),
      );
    });
  }
}

class _StatusBanner extends StatelessWidget {
  final String msg;
  final bool isError;
  const _StatusBanner({required this.msg, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF059669);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(fontSize: 13, color: color))),
      ]),
    );
  }
}
