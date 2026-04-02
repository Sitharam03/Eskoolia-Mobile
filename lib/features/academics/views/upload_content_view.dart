import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/upload_content_controller.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';
import '../../../core/widgets/school_loader.dart';

class UploadContentView extends GetView<UploadContentController> {
  const UploadContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Upload Content',
      body: Column(
        children: [
          const AcademicsNavTabs(
              activeRoute: AppRoutes.academicsUploadContent),
          Expanded(
            child: Obx(() {
              if (controller.years.isEmpty && controller.classes.isEmpty) {
                return const SchoolLoader();
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _UploadFormCard(controller: controller),
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

// ── Upload form card ──────────────────────────────────────────────────────────

class _UploadFormCard extends StatefulWidget {
  final UploadContentController controller;
  const _UploadFormCard({required this.controller});

  @override
  State<_UploadFormCard> createState() => _UploadFormCardState();
}

class _UploadFormCardState extends State<_UploadFormCard> {
  UploadContentController get c => widget.controller;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _sourceUrlCtrl;
  late final TextEditingController _fileUrlCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _uploadDateCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: c.contentTitle.value);
    _sourceUrlCtrl = TextEditingController(text: c.sourceUrl.value);
    _fileUrlCtrl = TextEditingController(text: c.uploadFile.value);
    _descCtrl = TextEditingController(text: c.description.value);
    _uploadDateCtrl = TextEditingController(text: c.uploadDate.value);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _sourceUrlCtrl.dispose();
    _fileUrlCtrl.dispose();
    _descCtrl.dispose();
    _uploadDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(c.uploadDate.value) ?? now,
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
      c.uploadDate.value = f;
      _uploadDateCtrl.text = f;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
              title: 'Content Details', icon: Icons.upload_file_rounded),
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
                        _none(),
                        ...c.years.map((y) => _dd(y.id.toString(), y.name)),
                      ],
                      onChanged: (v) => c.academicYearId.value = v ?? '',
                    ),
                    const SizedBox(height: 14),

                    // Content Type
                    aDropdown<String>(
                      value: c.contentType.value,
                      label: 'Content Type',
                      items: const [
                        DropdownMenuItem(value: 'as', child: Text('Assignment')),
                        DropdownMenuItem(value: 'st', child: Text('Study Material')),
                        DropdownMenuItem(value: 'sy', child: Text('Syllabus')),
                        DropdownMenuItem(value: 'ot', child: Text('Other Downloads')),
                      ],
                      onChanged: (v) => c.contentType.value = v ?? 'as',
                    ),
                    const SizedBox(height: 14),

                    // Content Title *
                    aTextField(_titleCtrl, 'Content Title *',
                        hint: 'Enter content title'),
                    const SizedBox(height: 14),

                    // Class (disabled if forAllClasses)
                    IgnorePointer(
                      ignoring: c.forAllClasses.value,
                      child: Opacity(
                        opacity: c.forAllClasses.value ? 0.4 : 1.0,
                        child: aDropdown<String>(
                          value: c.classId.value.isEmpty
                              ? null
                              : c.classId.value,
                          label: 'Class',
                          items: [
                            _none(),
                            ...c.classes.map(
                                (cl) => _dd(cl.id.toString(), cl.name)),
                          ],
                          onChanged: (v) {
                            c.classId.value = v ?? '';
                            c.sectionId.value = '';
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Section (disabled if forAllClasses or no class)
                    IgnorePointer(
                      ignoring: c.forAllClasses.value ||
                          c.classId.value.isEmpty,
                      child: Opacity(
                        opacity: (c.forAllClasses.value ||
                                c.classId.value.isEmpty)
                            ? 0.4
                            : 1.0,
                        child: aDropdown<String>(
                          value: c.sectionId.value.isEmpty
                              ? null
                              : c.sectionId.value,
                          label: 'Section',
                          items: [
                            _none(),
                            ...c.filteredSections
                                .map((s) => _dd(s.id.toString(), s.name)),
                          ],
                          onChanged: (v) => c.sectionId.value = v ?? '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Upload Date
                    _DateFieldRaw(
                        label: 'Upload Date',
                        ctrl: _uploadDateCtrl,
                        onTap: _pickDate),
                    const SizedBox(height: 14),

                    // Source URL
                    aTextField(_sourceUrlCtrl, 'Source URL',
                        hint: 'https://...'),
                    const SizedBox(height: 14),

                    // Upload File URL
                    aTextField(_fileUrlCtrl, 'Upload File URL',
                        hint: 'https://...'),
                    const SizedBox(height: 14),

                    // Description
                    aTextField(_descCtrl, 'Description',
                        hint: 'Enter description...', maxLines: 4),
                    const SizedBox(height: 8),

                    // Available for Admin
                    _CheckboxRow(
                      label: 'Available for Admin',
                      value: c.forAdmin.value,
                      onChanged: (v) => c.forAdmin.value = v ?? false,
                    ),
                    // Available for All Classes
                    _CheckboxRow(
                      label: 'Available for All Classes',
                      value: c.forAllClasses.value,
                      onChanged: (v) {
                        c.forAllClasses.value = v ?? false;
                        if (v == true) {
                          c.classId.value = '';
                          c.sectionId.value = '';
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Error / Success
                    if (c.uploadError.value.isNotEmpty)
                      _StatusBanner(
                          message: c.uploadError.value, isError: true),
                    if (c.uploadSuccess.value.isNotEmpty)
                      _StatusBanner(
                          message: c.uploadSuccess.value, isError: false),
                    if (c.uploadError.value.isNotEmpty ||
                        c.uploadSuccess.value.isNotEmpty)
                      const SizedBox(height: 8),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: aPrimaryBtn(
                        'Save Content',
                        c.isSaving.value
                            ? null
                            : () {
                                c.contentTitle.value = _titleCtrl.text;
                                c.sourceUrl.value = _sourceUrlCtrl.text;
                                c.uploadFile.value = _fileUrlCtrl.text;
                                c.description.value = _descCtrl.text;
                                c.submitUpload();
                              },
                        isLoading: c.isSaving.value,
                      ),
                    ),
                  ],
                )),
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

// ── Checkbox row ──────────────────────────────────────────────────────────────

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckboxRow(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4F46E5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF374151))),
        ]),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

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
