import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/online_exam_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class OnlineExamView extends StatelessWidget {
  const OnlineExamView({super.key});

  OnlineExamController get _c => Get.find<OnlineExamController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.onlineExam),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: () async {
                  _c.cancelEdit();
                  await _c.refresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    children: [
                      _FormCard(c: _c),
                      Obx(() {
                        if (_c.errorMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _StatusBanner(
                                msg: _c.errorMsg.value, isError: true),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.successMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _StatusBanner(
                                msg: _c.successMsg.value, isError: false),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      const SizedBox(height: 16),
                      _ExamListCard(c: _c),
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

class _FormCard extends StatelessWidget {
  final OnlineExamController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sectionHeader(c.editingId.value != null
                      ? 'Edit Online Exam'
                      : 'Add Online Exam'),
                  if (c.editingId.value != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF6B7280), size: 20),
                      onPressed: c.cancelEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              sFieldLabel('Title'),
              const SizedBox(height: 6),
              sTextField(controller: c.titleCtrl, hint: 'Exam title'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Duration (min)'),
                        const SizedBox(height: 6),
                        sTextField(
                            controller: c.durationCtrl,
                            hint: '60',
                            keyboardType: TextInputType.number),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Total Marks'),
                        const SizedBox(height: 6),
                        sTextField(
                            controller: c.totalMarkCtrl,
                            hint: '100',
                            keyboardType: TextInputType.number),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Pass Marks'),
                        const SizedBox(height: 6),
                        sTextField(
                            controller: c.passMarkCtrl,
                            hint: '40',
                            keyboardType: TextInputType.number),
                      ]),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Start Date'),
                        const SizedBox(height: 6),
                        _DateField(
                          controller: c.startDateCtrl,
                        ),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('End Date'),
                        const SizedBox(height: 6),
                        _DateField(
                          controller: c.endDateCtrl,
                        ),
                      ]),
                ),
              ]),
              const SizedBox(height: 12),
              sFieldLabel('Class'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedClassId.value,
                hint: 'Select Class',
                items: c.classes
                    .map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.name)))
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
                hint: 'Select Section',
                items: c.filteredSections
                    .map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.name)))
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
                    .map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => c.selectedSubjectId.value = v,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: c.isSaving.value ? null : c.save,
                  icon: c.isSaving.value
                      ? sSavingIndicator()
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                      c.isSaving.value
                          ? 'Saving…'
                          : (c.editingId.value != null
                              ? 'Update'
                              : 'Create Exam'),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  const _DateField({required this.controller});

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return sTextField(
      controller: controller,
      hint: 'YYYY-MM-DD',
      readOnly: true,
      onTap: () => _pick(context),
      suffixIcon: const Icon(Icons.calendar_today_rounded,
          size: 18, color: Color(0xFF9CA3AF)),
    );
  }
}

class _ExamListCard extends StatelessWidget {
  final OnlineExamController c;
  const _ExamListCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Online Exams'),
        const SizedBox(height: 12),
        Obx(() {
          if (c.exams.isEmpty) {
            return sEmptyState('No online exams yet', Icons.quiz_outlined);
          }
          return Column(
              children:
                  c.exams.map((e) => _ExamRow(exam: e, c: c)).toList());
        }),
      ]),
    );
  }
}

class _ExamRow extends StatelessWidget {
  final OnlineExam exam;
  final OnlineExamController c;
  const _ExamRow({required this.exam, required this.c});

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
            child: Text(exam.title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
          ),
          sBadge(
              exam.isPublished ? 'Published' : 'Draft',
              exam.isPublished
                  ? const Color(0xFF059669)
                  : const Color(0xFF6B7280)),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 12, runSpacing: 4, children: [
          _Detail(
              icon: Icons.class_rounded,
              text: '${exam.className} ${exam.sectionName}'),
          _Detail(icon: Icons.book_rounded, text: exam.subjectName),
          _Detail(
              icon: Icons.timer_rounded, text: '${exam.duration} min'),
          _Detail(
              icon: Icons.score_rounded,
              text: '${exam.totalMark} marks (pass: ${exam.passMark})'),
          _Detail(
              icon: Icons.date_range_rounded,
              text: '${exam.startDate} → ${exam.endDate}'),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          sIconBtn(Icons.edit_rounded, const Color(0xFF4F46E5),
              () => c.startEdit(exam)),
          sIconBtn(
              exam.isPublished
                  ? Icons.unpublished_rounded
                  : Icons.publish_rounded,
              exam.isPublished
                  ? const Color(0xFFEA580C)
                  : const Color(0xFF059669),
              () => c.togglePublish(exam)),
          sIconBtn(Icons.delete_outline_rounded, const Color(0xFFDC2626),
              () {
            showDialog(
              context: context,
              builder: (_) => sDeleteDialog(
                context: context,
                message: 'Are you sure you want to delete "${exam.title}"?',
                onConfirm: () => c.delete(exam.id),
              ),
            );
          }),
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
