import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/students/views/_student_shared.dart';
import '../controllers/exam_marks_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';

class ExamMarksCreateView extends StatelessWidget {
  const ExamMarksCreateView({super.key});

  ExamMarksController get _c => Get.find<ExamMarksController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add Marks',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examMarksCreate),
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
                    Obx(() {
                      if (_c.students.isEmpty || _c.parts.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _MarksTable(c: _c);
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
  final ExamMarksController c;
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
            if (c.successMsg.value.isNotEmpty) {
              return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _StatusBanner(message: c.successMsg.value, isError: false));
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

// ── Marks Table ───────────────────────────────────────────────────────────────

class _MarksTable extends StatelessWidget {
  final ExamMarksController c;
  const _MarksTable({required this.c});

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
              Expanded(
                child: Obx(() => Text(
                      '${c.students.length} Student${c.students.length == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827)),
                    )),
              ),
              Obx(() => c.parts.isNotEmpty
                  ? Text(
                      '${c.parts.length} part${c.parts.length == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280)),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() => Column(
                children: c.students
                    .map((s) => _StudentMarksCard(student: s, c: c))
                    .toList(),
              )),
          const SizedBox(height: 14),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.isSaving.value ? null : c.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: c.isSaving.value
                      ? sSavingIndicator()
                      : Text('Save Marks',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              )),
        ],
      ),
    );
  }
}

class _StudentMarksCard extends StatelessWidget {
  final MarksStudentRow student;
  final ExamMarksController c;

  const _StudentMarksCard({required this.student, required this.c});

  @override
  Widget build(BuildContext context) {
    final initials = student.firstName.isNotEmpty
        ? student.firstName[0].toUpperCase() +
            (student.lastName.isNotEmpty
                ? student.lastName[0].toUpperCase()
                : '')
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
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
                    Text(student.fullName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF111827))),
                    Text('Adm: ${student.admissionNo}'
                        '${student.rollNo.isNotEmpty ? ' · Roll: ${student.rollNo}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              // Absent toggle
              Obx(() {
                final isAbsent = c.absentState[student.studentRecordId] ?? false;
                return GestureDetector(
                  onTap: () => c.toggleAbsent(student.studentRecordId, !isAbsent),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isAbsent
                          ? const Color(0xFFDC2626).withValues(alpha: 0.1)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isAbsent
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFD1D5DB)),
                    ),
                    child: Text(
                      isAbsent ? 'Absent' : 'Present',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAbsent
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF6B7280)),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          // Marks per part
          Obx(() => Column(
                children: c.parts
                    .map((part) => _MarkInput(
                          label: '${part.examTitle} (max ${part.examMark})',
                          studentRecordId: student.studentRecordId,
                          setupId: part.id,
                          c: c,
                        ))
                    .toList(),
              )),
          const SizedBox(height: 8),
          // Teacher remarks
          sFieldLabel('Teacher Remarks'),
          const SizedBox(height: 4),
          _RemarksInput(studentRecordId: student.studentRecordId, c: c),
        ],
      ),
    );
  }
}

class _MarkInput extends StatefulWidget {
  final String label;
  final int studentRecordId;
  final int setupId;
  final ExamMarksController c;

  const _MarkInput({
    required this.label,
    required this.studentRecordId,
    required this.setupId,
    required this.c,
  });

  @override
  State<_MarkInput> createState() => _MarkInputState();
}

class _MarkInputState extends State<_MarkInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final val = widget.c.marksState[widget.studentRecordId]
            ?[widget.setupId.toString()] ??
        '0';
    _ctrl = TextEditingController(text: val);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF374151),
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: sTextField(
              controller: _ctrl,
              hint: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) =>
                  widget.c.updateMark(widget.studentRecordId, widget.setupId, v),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemarksInput extends StatefulWidget {
  final int studentRecordId;
  final ExamMarksController c;

  const _RemarksInput(
      {required this.studentRecordId, required this.c});

  @override
  State<_RemarksInput> createState() => _RemarksInputState();
}

class _RemarksInputState extends State<_RemarksInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.c.remarksState[widget.studentRecordId] ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sTextField(
      controller: _ctrl,
      hint: 'Optional remarks',
      onChanged: (v) => widget.c.updateRemarks(widget.studentRecordId, v),
    );
  }
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
