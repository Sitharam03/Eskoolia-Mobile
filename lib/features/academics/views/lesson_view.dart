import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/lesson_controller.dart';
import '../models/academics_models.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';
import '../../../core/widgets/school_loader.dart';

class LessonView extends GetView<LessonController> {
  const LessonView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Lessons',
      body: Column(
        children: [
          const AcademicsNavTabs(activeRoute: AppRoutes.academicsLessons),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _CreateFormCard(controller: controller),
                  const SizedBox(height: 16),
                  _LessonRowsCard(controller: controller),
                  const SizedBox(height: 16),
                  _LessonGroupReportCard(controller: controller),
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

// ── Section 1: Create form card ───────────────────────────────────────────────

class _CreateFormCard extends StatefulWidget {
  final LessonController controller;
  const _CreateFormCard({required this.controller});

  @override
  State<_CreateFormCard> createState() => _CreateFormCardState();
}

class _CreateFormCardState extends State<_CreateFormCard> {
  LessonController get c => widget.controller;
  late final TextEditingController _lessonTextCtrl;

  @override
  void initState() {
    super.initState();
    _lessonTextCtrl = TextEditingController(text: c.lessonText.value);
  }

  @override
  void dispose() {
    _lessonTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Create Lessons',
      icon: Icons.add_box_rounded,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Year
              aDropdown<String>(
                value: c.academicYearId.value.isEmpty
                    ? null
                    : c.academicYearId.value,
                label: 'Academic Year',
                items: [
                  _none(),
                  ...c.years.map((y) => _dd(y.id.toString(), y.name)),
                ],
                onChanged: (v) => c.academicYearId.value = v ?? '',
              ),
              const SizedBox(height: 14),

              // Class *
              aDropdown<String>(
                value: c.classId.value.isEmpty ? null : c.classId.value,
                label: 'Class *',
                items: c.classes
                    .map((cl) => _dd(cl.id.toString(), cl.name))
                    .toList(),
                onChanged: (v) {
                  c.classId.value = v ?? '';
                  c.sectionId.value = '';
                },
              ),
              const SizedBox(height: 14),

              // Section
              aDropdown<String>(
                value: c.sectionId.value.isEmpty ? null : c.sectionId.value,
                label: 'Section',
                items: [
                  _none(),
                  ...c.filteredSections
                      .map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) => c.sectionId.value = v ?? '',
              ),
              const SizedBox(height: 14),

              // Subject *
              aDropdown<String>(
                value: c.subjectId.value.isEmpty ? null : c.subjectId.value,
                label: 'Subject *',
                items: c.subjects
                    .map((s) => _dd(s.id.toString(), s.name))
                    .toList(),
                onChanged: (v) {
                  c.subjectId.value = v ?? '';
                  c.loadLessons();
                  c.loadGroups();
                },
              ),
              const SizedBox(height: 14),

              // Lesson titles textarea
              aTextField(
                _lessonTextCtrl,
                'Lesson Titles (one per line)',
                hint:
                    'e.g.\nIntroduction to Algebra\nBasic Equations',
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // Error / success
              if (c.error.value.isNotEmpty)
                _StatusBanner(message: c.error.value, isError: true),
              if (c.message.value.isNotEmpty)
                _StatusBanner(message: c.message.value, isError: false),

              // Buttons
              Row(children: [
                Expanded(
                  child: aDangerBtn(
                    'Delete Selected Group',
                    c.isSaving.value
                        ? null
                        : () => _confirmDeleteGroup(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: aPrimaryBtn(
                    c.isSaving.value ? 'Saving...' : 'Save Lessons',
                    c.isSaving.value
                        ? null
                        : () async {
                            c.lessonText.value = _lessonTextCtrl.text;
                            await c.submitLessons();
                            if (c.error.value.isEmpty) {
                              _lessonTextCtrl.clear();
                            }
                          },
                    isLoading: c.isSaving.value,
                  ),
                ),
              ]),
            ],
          )),
    );
  }

  void _confirmDeleteGroup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFDC2626), size: 22),
          const SizedBox(width: 8),
          Text('Delete Lesson Group',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: Text(
            'Delete all lessons for the selected class/section/subject?',
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
              c.deleteGroup();
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

  static DropdownMenuItem<String> _none() =>
      DropdownMenuItem(
          value: '',
          child: Text('-- None --',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF6B7280))));

  static DropdownMenuItem<String> _dd(String v, String label) =>
      DropdownMenuItem(
          value: v,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF111827))));
}

// ── Section 2: Lesson rows ────────────────────────────────────────────────────

class _LessonRowsCard extends StatelessWidget {
  final LessonController controller;
  const _LessonRowsCard({required this.controller});

  LessonController get c => controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Lesson Rows',
      icon: Icons.list_alt_rounded,
      child: Obx(() {
        if (c.isLoading.value) {
          return const SchoolLoader();
        }
        if (c.lessons.isEmpty) {
          return aEmptyState(
              'No lessons yet.\nSelect class & subject then add lessons.');
        }
        return Column(
          children: c.lessons
              .map((lesson) =>
                  _LessonRow(lesson: lesson, controller: c))
              .toList(),
        );
      }),
    );
  }
}

class _LessonRow extends StatefulWidget {
  final Lesson lesson;
  final LessonController controller;
  const _LessonRow({required this.lesson, required this.controller});

  @override
  State<_LessonRow> createState() => _LessonRowState();
}

class _LessonRowState extends State<_LessonRow> {
  late final TextEditingController _editCtrl;
  LessonController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _editCtrl = TextEditingController(text: widget.lesson.lessonTitle);
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = c.editingId.value == widget.lesson.id;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isEditing
              ? const Color(0xFFF5F3FF)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEditing
                ? const Color(0xFF4F46E5).withValues(alpha: 0.4)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(children: [
          // ID badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('${widget.lesson.id}',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4F46E5))),
            ),
          ),
          const SizedBox(width: 12),
          // Title / edit field
          Expanded(
            child: isEditing
                ? aTextField(_editCtrl, '', hint: 'Lesson title')
                : Text(widget.lesson.lessonTitle,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF111827))),
          ),
          const SizedBox(width: 8),
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check_rounded,
                  color: Color(0xFF16A34A), size: 20),
              onPressed: () {
                c.editingTitle.value = _editCtrl.text;
                c.saveEdit(widget.lesson);
              },
              tooltip: 'Save',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Color(0xFF6B7280), size: 20),
              onPressed: () {
                c.editingId.value = null;
                _editCtrl.text = widget.lesson.lessonTitle;
              },
              tooltip: 'Cancel',
              visualDensity: VisualDensity.compact,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  color: Color(0xFF4F46E5), size: 18),
              onPressed: () {
                _editCtrl.text = widget.lesson.lessonTitle;
                c.startEdit(widget.lesson);
              },
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626), size: 18),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ]),
      );
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Lesson',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Delete "${widget.lesson.lessonTitle}"?',
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
              c.deleteLesson(widget.lesson.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('Delete',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Section 3: Lesson group report ────────────────────────────────────────────

class _LessonGroupReportCard extends StatelessWidget {
  final LessonController controller;
  const _LessonGroupReportCard({required this.controller});

  LessonController get c => controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Lesson Group Report',
      icon: Icons.table_chart_rounded,
      child: Obx(() {
        if (c.groups.isEmpty) {
          return aEmptyState('No lesson groups loaded.');
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
              DataColumn(label: Text('Class')),
              DataColumn(label: Text('Section')),
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Lesson Titles')),
            ],
            rows: c.groups.map((group) {
              final titles =
                  group.items.map((l) => l.lessonTitle).join(', ');
              return DataRow(cells: [
                DataCell(Text(c.className(group.classId))),
                DataCell(Text(c.sectionName(group.sectionId))),
                DataCell(Text(c.subjectName(group.subjectId))),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(titles,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ]);
            }).toList(),
          ),
        );
      }),
    );
  }
}

// ── Shared section card widget ────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F3FF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(children: [
            Icon(icon, color: const Color(0xFF4F46E5), size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF4F46E5))),
          ]),
        ),
        Padding(
            padding: const EdgeInsets.all(16), child: child),
      ]),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final bg =
        isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
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
