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

class HomeworkListView extends GetView<HomeworkController> {
  const HomeworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Homework List',
      body: Column(
        children: [
          const AcademicsNavTabs(activeRoute: AppRoutes.academicsHomeworkList),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _FilterCard(controller: controller),
                  const SizedBox(height: 16),
                  _HomeworkList(controller: controller),
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
              aSectionHeader('Filter Homework'),

              aDropdown<String>(
                value: c.filterClassId.value.isEmpty
                    ? null
                    : c.filterClassId.value,
                label: 'Class',
                items: [
                  _none('All classes'),
                  ...c.classes.map((cl) => _dd(cl.id.toString(), cl.name)),
                ],
                onChanged: (v) {
                  c.filterClassId.value = v ?? '';
                  c.filterSectionId.value = '';
                },
              ),
              const SizedBox(height: 12),

              aDropdown<String>(
                value: c.filterSectionId.value.isEmpty
                    ? null
                    : c.filterSectionId.value,
                label: 'Section',
                items: [
                  _none('All sections'),
                  ...c.filterSections.map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) => c.filterSectionId.value = v ?? '',
              ),
              const SizedBox(height: 12),

              aDropdown<String>(
                value: c.filterSubjectId.value.isEmpty
                    ? null
                    : c.filterSubjectId.value,
                label: 'Subject',
                items: [
                  _none('All subjects'),
                  ...c.subjects.map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) => c.filterSubjectId.value = v ?? '',
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: aPrimaryBtn('Search', () => c.loadHomeworks()),
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

// ── Homework list ─────────────────────────────────────────────────────────────

class _HomeworkList extends StatelessWidget {
  final HomeworkController controller;
  const _HomeworkList({required this.controller});

  HomeworkController get c => controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const SchoolLoader();
      }
      if (c.homeworks.isEmpty) {
        return aEmptyState('No homework found.\nUse filters above to search.');
      }
      return Column(
        children: c.homeworks
            .map((hw) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HomeworkCard(hw: hw, controller: c),
                ))
            .toList(),
      );
    });
  }
}

// ── Homework card ─────────────────────────────────────────────────────────────

class _HomeworkCard extends StatelessWidget {
  final Homework hw;
  final HomeworkController controller;
  const _HomeworkCard({required this.hw, required this.controller});

  HomeworkController get c => controller;

  String get _subjectName {
    final s = c.subjects.firstWhereOrNull((s) => s.id == hw.subjectId);
    return s?.name ?? '#${hw.subjectId}';
  }

  String get _className {
    final cl = c.classes.firstWhereOrNull((cl) => cl.id == hw.classId);
    return cl?.name ?? '#${hw.classId}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_subjectName,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF4F46E5))),
                  Text(_className,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280))),
                ]),
              ),
              aBadge('HW #${hw.id}', const Color(0xFF4F46E5)),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Homework Date', value: hw.homeworkDate),
                _InfoRow(label: 'Submission Date', value: hw.submissionDate),
                _InfoRow(label: 'Marks', value: hw.marks.toString()),
                _InfoRow(
                    label: 'Evaluation Date',
                    value: hw.evaluationDate ?? '-'),
                if (hw.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    hw.description.length > 120
                        ? '${hw.description.substring(0, 120)}...'
                        : hw.description,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF374151)),
                  ),
                ],
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _openEvaluation(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Evaluation',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _confirmDelete(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text('Delete',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFDC2626), size: 22),
          const SizedBox(width: 8),
          Text('Delete Homework',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: Text('Delete this homework record?',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              c.deleteHomework(hw.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('Delete',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _openEvaluation(BuildContext context) async {
    await c.openEvaluation(hw);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EvaluationSheet(controller: c, homework: hw),
    );
  }
}

// ── Evaluation bottom sheet ───────────────────────────────────────────────────

class _EvaluationSheet extends StatefulWidget {
  final HomeworkController controller;
  final Homework homework;
  const _EvaluationSheet({required this.controller, required this.homework});

  @override
  State<_EvaluationSheet> createState() => _EvaluationSheetState();
}

class _EvaluationSheetState extends State<_EvaluationSheet> {
  HomeworkController get c => widget.controller;
  late final TextEditingController _evalDateCtrl;

  @override
  void initState() {
    super.initState();
    _evalDateCtrl = TextEditingController(text: c.evaluationDate.value);
  }

  @override
  void dispose() {
    _evalDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(0xFF4F46E5))),
        child: child!,
      ),
    );
    if (picked != null) {
      final f =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      c.evaluationDate.value = f;
      _evalDateCtrl.text = f;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: Text('Homework Evaluation',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF6B7280))),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final students = c.filteredStudents;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Evaluation date
                      _DateFieldRaw(
                          label: 'Evaluation Date',
                          ctrl: _evalDateCtrl,
                          onTap: _pickDate),
                      const SizedBox(height: 16),
                      Text('Students (${students.length})',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF374151))),
                      const SizedBox(height: 10),
                      if (students.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: aEmptyState('No students for this class/section.'),
                        ),
                      ...students.map((st) =>
                          _StudentEvalRow(student: st, controller: c)),
                      const SizedBox(height: 16),
                      if (c.evalError.value.isNotEmpty)
                        _StatusBanner(
                            message: c.evalError.value, isError: true),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: c.savingEval.value
                                ? null
                                : () async {
                                    await c.saveEvaluation();
                                    if (context.mounted &&
                                        c.evalError.value.isEmpty) {
                                      Navigator.pop(context);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: c.savingEval.value
                                ? aSavingIndicator()
                                : Text('Save Evaluation',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('Cancel',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student evaluation row ────────────────────────────────────────────────────

class _StudentEvalRow extends StatefulWidget {
  final StudentRecord student;
  final HomeworkController controller;
  const _StudentEvalRow({required this.student, required this.controller});

  @override
  State<_StudentEvalRow> createState() => _StudentEvalRowState();
}

class _StudentEvalRowState extends State<_StudentEvalRow> {
  late final TextEditingController _marksCtrl;
  late final TextEditingController _noteCtrl;
  HomeworkController get c => widget.controller;
  StudentRecord get st => widget.student;

  @override
  void initState() {
    super.initState();
    final draft = c.drafts[st.id] ?? {};
    _marksCtrl = TextEditingController(text: draft['obtained_marks'] ?? '');
    _noteCtrl = TextEditingController(text: draft['note'] ?? '');
  }

  @override
  void dispose() {
    _marksCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            aBadge(st.admissionNo, const Color(0xFF4F46E5)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(st.fullName,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF111827))),
            ),
          ]),
          const SizedBox(height: 10),
          Obx(() {
            final draft = c.drafts[st.id] ?? {};
            return Row(children: [
              Expanded(
                flex: 2,
                child: aDropdown<String>(
                  value: draft['status']?.isEmpty == true
                      ? null
                      : draft['status'],
                  label: 'Status',
                  items: const [
                    DropdownMenuItem(value: 'C', child: Text('Completed')),
                    DropdownMenuItem(value: 'I', child: Text('Incomplete')),
                    DropdownMenuItem(value: 'P', child: Text('Pending')),
                  ],
                  onChanged: (v) => c.setDraft(st.id, 'status', v ?? ''),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: aTextField(
                  _marksCtrl,
                  'Marks',
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ]);
          }),
          const SizedBox(height: 8),
          aTextField(_noteCtrl, 'Note', hint: 'Optional note...', maxLines: 2),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF111827))),
        ),
      ]),
    );
  }
}

class _DateFieldRaw extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final VoidCallback onTap;
  const _DateFieldRaw(
      {required this.label, required this.ctrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
        suffixIcon: const Icon(Icons.calendar_today_rounded,
            size: 18, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final bg = isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(message,
          style: GoogleFonts.inter(
              fontSize: 13, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
