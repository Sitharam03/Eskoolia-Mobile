import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/homework_controller.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';
import '../../../core/widgets/school_loader.dart';

class HomeworkAddView extends GetView<HomeworkController> {
  const HomeworkAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add Homework',
      body: Column(
        children: [
          const AcademicsNavTabs(activeRoute: AppRoutes.academicsHomeworkAdd),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.classes.isEmpty) {
                return const SchoolLoader();
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _FormCard(controller: controller),
                    const SizedBox(height: 40),
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

// ── Form card ────────────────────────────────────────────────────────────────

class _FormCard extends StatefulWidget {
  final HomeworkController controller;
  const _FormCard({required this.controller});

  @override
  State<_FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<_FormCard> {
  HomeworkController get c => widget.controller;

  late final TextEditingController _marksCtrl;
  late final TextEditingController _fileCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _hwDateCtrl;
  late final TextEditingController _subDateCtrl;

  @override
  void initState() {
    super.initState();
    _marksCtrl = TextEditingController(text: c.marks.value);
    _fileCtrl = TextEditingController(text: c.file.value);
    _descCtrl = TextEditingController(text: c.description.value);
    _hwDateCtrl = TextEditingController(text: c.homeworkDate.value);
    _subDateCtrl = TextEditingController(text: c.submissionDate.value);
  }

  @override
  void dispose() {
    _marksCtrl.dispose();
    _fileCtrl.dispose();
    _descCtrl.dispose();
    _hwDateCtrl.dispose();
    _subDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
      BuildContext ctx, RxString target, TextEditingController ctrl) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(target.value) ?? now;
    final picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
            colorScheme:
                const ColorScheme.light(primary: Color(0xFF4F46E5))),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      target.value = formatted;
      ctrl.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(title: 'Homework Details', icon: Icons.assignment_rounded),
          Padding(
            padding: const EdgeInsets.all(16),
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
                        _buildNoneItem(),
                        ...c.years.map((y) => _ddItem(y.id.toString(), y.name)),
                      ],
                      onChanged: (v) => c.academicYearId.value = v ?? '',
                    ),
                    const SizedBox(height: 14),

                    // Class *
                    aDropdown<String>(
                      value: c.addClassId.value.isEmpty ? null : c.addClassId.value,
                      label: 'Class *',
                      items: c.classes
                          .map((cl) => _ddItem(cl.id.toString(), cl.name))
                          .toList(),
                      onChanged: (v) {
                        c.addClassId.value = v ?? '';
                        c.addSectionId.value = '';
                      },
                    ),
                    const SizedBox(height: 14),

                    // Section
                    aDropdown<String>(
                      value: c.addSectionId.value.isEmpty
                          ? null
                          : c.addSectionId.value,
                      label: 'Section',
                      items: [
                        _buildNoneItem(),
                        ...c.addAvailableSections
                            .map((s) => _ddItem(s.id.toString(), s.name)),
                      ],
                      onChanged: (v) => c.addSectionId.value = v ?? '',
                    ),
                    const SizedBox(height: 14),

                    // Subject *
                    aDropdown<String>(
                      value: c.addSubjectId.value.isEmpty
                          ? null
                          : c.addSubjectId.value,
                      label: 'Subject *',
                      items: c.subjects
                          .map((s) => _ddItem(s.id.toString(), s.name))
                          .toList(),
                      onChanged: (v) => c.addSubjectId.value = v ?? '',
                    ),
                    const SizedBox(height: 14),

                    // Homework Date + Submission Date
                    Row(children: [
                      Expanded(
                        child: _DateField(
                          label: 'Homework Date',
                          ctrl: _hwDateCtrl,
                          onTap: () => _pickDate(
                              context, c.homeworkDate, _hwDateCtrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'Submission Date',
                          ctrl: _subDateCtrl,
                          onTap: () => _pickDate(
                              context, c.submissionDate, _subDateCtrl),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    // Marks
                    aTextField(_marksCtrl, 'Marks',
                        hint: 'e.g. 100',
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 14),

                    // Attachment URL
                    aTextField(_fileCtrl, 'Attachment URL',
                        hint: 'https://...'),
                    const SizedBox(height: 14),

                    // Description
                    aTextField(_descCtrl, 'Description',
                        hint: 'Enter homework description...',
                        maxLines: 4),
                    const SizedBox(height: 20),

                    // Sync changes back to controller when user stops editing
                    // (TextFormField onChange alternative)
                    _SyncListener(
                        marksCtrl: _marksCtrl,
                        fileCtrl: _fileCtrl,
                        descCtrl: _descCtrl,
                        c: c),

                    // Error / success
                    if (c.addError.value.isNotEmpty)
                      _StatusBanner(message: c.addError.value, isError: true),
                    if (c.addSuccess.value.isNotEmpty)
                      _StatusBanner(message: c.addSuccess.value, isError: false),
                    if (c.addError.value.isNotEmpty || c.addSuccess.value.isNotEmpty)
                      const SizedBox(height: 12),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: c.isSaving.value
                            ? null
                            : () {
                                // Flush controllers to observables before submit
                                c.marks.value = _marksCtrl.text;
                                c.file.value = _fileCtrl.text;
                                c.description.value = _descCtrl.text;
                                c.submitHomework();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: c.isSaving.value
                            ? aSavingIndicator()
                            : Text(
                                'Save Homework',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  static DropdownMenuItem<String> _ddItem(String v, String label) =>
      DropdownMenuItem(
          value: v,
          child: Text(label,
              style: GoogleFonts.inter(fontSize: 14,
                  color: const Color(0xFF111827))));

  static DropdownMenuItem<String> _buildNoneItem() =>
      DropdownMenuItem(
          value: '',
          child: Text('-- None --',
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF6B7280))));
}

// Invisible widget that syncs TextEditingControllers to Rx observables on build
class _SyncListener extends StatelessWidget {
  final TextEditingController marksCtrl;
  final TextEditingController fileCtrl;
  final TextEditingController descCtrl;
  final HomeworkController c;
  const _SyncListener(
      {required this.marksCtrl,
      required this.fileCtrl,
      required this.descCtrl,
      required this.c});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ── Shared card widgets ───────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _CardHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final VoidCallback onTap;
  const _DateField(
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: GoogleFonts.inter(
                  fontSize: 13, color: color, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}
