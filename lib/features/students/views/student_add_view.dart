import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_add_controller.dart';
import '../models/student_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentAddView extends StatefulWidget {
  const StudentAddView({super.key});
  @override
  State<StudentAddView> createState() => _StudentAddViewState();
}

class _StudentAddViewState extends State<StudentAddView> {
  StudentAddController get _c => Get.find<StudentAddController>();

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing an existing student (passed via arguments)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args['student'] is StudentRow) {
        _c.startEdit(args['student'] as StudentRow);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add / Edit Student',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentAdd),
        Obx(() {
          if (_c.isLoading.value) {
            return const Expanded(child: SchoolLoader());
          }
          return Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildBasicInfo(),
                const SizedBox(height: 16),
                _buildAcademicInfo(),
                const SizedBox(height: 16),
                _buildGuardianSection(),
                const SizedBox(height: 16),
                _buildStatusToggles(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  // ── Basic Info Card ──────────────────────────────────────────────────────────
  Widget _buildBasicInfo() {
    return _SectionCard(
      title: 'Basic Information',
      icon: Icons.person_rounded,
      child: Column(children: [
        Row(children: [
          Expanded(child: _FieldBlock(
            label: 'Admission No *',
            child: sTextField(
                controller: _c.admissionNoCtrl,
                hint: 'e.g. ADM2024001'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _FieldBlock(
            label: 'Roll No',
            child: sTextField(
                controller: _c.rollNoCtrl,
                hint: 'Optional',
                keyboardType: TextInputType.number),
          )),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _FieldBlock(
            label: 'First Name *',
            child: sTextField(
                controller: _c.firstNameCtrl, hint: 'First name'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _FieldBlock(
            label: 'Last Name',
            child: sTextField(
                controller: _c.lastNameCtrl, hint: 'Last name'),
          )),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _FieldBlock(
            label: 'Gender *',
            child: Obx(() => sDropdown<String>(
              value: _c.selectedGender.value.isEmpty
                  ? null
                  : _c.selectedGender.value,
              hint: 'Select gender',
              items: StudentAddController.genderOptions
                  .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(
                          g[0].toUpperCase() + g.substring(1))))
                  .toList(),
              onChanged: (v) => _c.selectedGender.value = v ?? '',
            )),
          )),
          const SizedBox(width: 12),
          Expanded(child: _FieldBlock(
            label: 'Blood Group',
            child: Obx(() => sDropdown<String>(
              value: _c.selectedBloodGroup.value,
              hint: 'Select',
              items: StudentAddController.bloodGroupOptions
                  .map((bg) => DropdownMenuItem(
                      value: bg, child: Text(bg)))
                  .toList(),
              onChanged: (v) => _c.selectedBloodGroup.value = v,
            )),
          )),
        ]),
        const SizedBox(height: 14),
        _FieldBlock(
          label: 'Date of Birth',
          child: sTextField(
            controller: _c.dobCtrl,
            hint: 'YYYY-MM-DD',
            readOnly: true,
            keyboardType: TextInputType.datetime,
            onTap: () => _pickDate(context),
            suffixIcon: const Icon(Icons.calendar_today_rounded,
                size: 18, color: Color(0xFF9CA3AF)),
          ),
        ),
      ]),
    );
  }

  // ── Academic Info Card ───────────────────────────────────────────────────────
  Widget _buildAcademicInfo() {
    return _SectionCard(
      title: 'Academic Information',
      icon: Icons.school_rounded,
      child: Column(children: [
        _FieldBlock(
          label: 'Category',
          child: Obx(() => sDropdown<int>(
            value: _c.selectedCategoryId.value,
            hint: 'Select category',
            items: [
              const DropdownMenuItem(value: null, child: Text('No category')),
              ..._c.categories.map((cat) => DropdownMenuItem(
                  value: cat.id, child: Text(cat.name))),
            ],
            onChanged: (v) => _c.selectedCategoryId.value = v,
          )),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _FieldBlock(
            label: 'Class',
            child: Obx(() => sDropdown<int>(
              value: _c.selectedClassId.value,
              hint: 'Select class',
              items: [
                const DropdownMenuItem(value: null, child: Text('No class')),
                ..._c.classes.map((c) => DropdownMenuItem(
                    value: c['id'] as int,
                    child: Text(c['name'] as String? ?? ''))),
              ],
              onChanged: (v) {
                _c.selectedClassId.value = v;
                _c.selectedSectionId.value = null;
              },
            )),
          )),
          const SizedBox(width: 12),
          Expanded(child: _FieldBlock(
            label: 'Section',
            child: Obx(() => sDropdown<int>(
              value: _c.selectedSectionId.value,
              hint: 'Select section',
              items: [
                const DropdownMenuItem(value: null, child: Text('No section')),
                ..._c.filteredSections.map((s) => DropdownMenuItem(
                    value: s['id'] as int,
                    child: Text(s['name'] as String? ?? ''))),
              ],
              onChanged: (v) => _c.selectedSectionId.value = v,
            )),
          )),
        ]),
      ]),
    );
  }

  // ── Guardian Card ────────────────────────────────────────────────────────────
  Widget _buildGuardianSection() {
    return _SectionCard(
      title: 'Guardian Information',
      icon: Icons.family_restroom_rounded,
      child: Column(children: [
        _FieldBlock(
          label: 'Select Guardian',
          child: Obx(() => sDropdown<int>(
            value: _c.selectedGuardianId.value,
            hint: 'Search or select guardian',
            items: [
              const DropdownMenuItem(value: null, child: Text('No guardian')),
              ..._c.guardians.map((g) => DropdownMenuItem(
                  value: g.id, child: Text(g.displayLabel))),
            ],
            onChanged: (v) => _c.selectedGuardianId.value = v,
          )),
        ),
        const SizedBox(height: 12),
        Obx(() => GestureDetector(
              onTap: () => _c.showGuardianForm.value =
                  !_c.showGuardianForm.value,
              child: Row(children: [
                Icon(
                    _c.showGuardianForm.value
                        ? Icons.expand_less_rounded
                        : Icons.add_circle_outline_rounded,
                    color: const Color(0xFF4F46E5),
                    size: 18),
                const SizedBox(width: 6),
                Text(
                  _c.showGuardianForm.value
                      ? 'Hide guardian form'
                      : 'Create new guardian',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600),
                ),
              ]),
            )),
        Obx(() => _c.showGuardianForm.value
            ? Column(children: [
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Column(children: [
                    sSectionDivider('NEW GUARDIAN'),
                    _FieldBlock(
                      label: 'Full Name *',
                      child: sTextField(
                          controller: _c.guardianNameCtrl,
                          hint: 'Guardian full name'),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: _FieldBlock(
                        label: 'Relation',
                        child: sTextField(
                            controller: _c.guardianRelationCtrl,
                            hint: 'Father/Mother/Other'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _FieldBlock(
                        label: 'Phone',
                        child: sTextField(
                          controller: _c.guardianPhoneCtrl,
                          hint: 'Phone number',
                          keyboardType: TextInputType.phone,
                        ),
                      )),
                    ]),
                    const SizedBox(height: 10),
                    _FieldBlock(
                      label: 'Email',
                      child: sTextField(
                        controller: _c.guardianEmailCtrl,
                        hint: 'guardian@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton.icon(
                        onPressed: _c.isSaving.value
                            ? null
                            : _c.saveGuardianInline,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: _c.isSaving.value
                            ? sSavingIndicator()
                            : const Icon(Icons.save_rounded, size: 16),
                        label: Text('Create Guardian',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600)),
                      )),
                    ),
                  ]),
                ),
              ])
            : const SizedBox.shrink()),
      ]),
    );
  }

  // ── Status Toggles ───────────────────────────────────────────────────────────
  Widget _buildStatusToggles() {
    return _SectionCard(
      title: 'Status',
      icon: Icons.toggle_on_rounded,
      child: Column(children: [
        Obx(() => _SwitchRow(
          label: 'Active Student',
          subtitle: 'Student can log in and access school features',
          value: _c.isActive.value,
          onChanged: (v) => _c.isActive.value = v,
          activeColor: const Color(0xFF16A34A),
        )),
        const Divider(height: 1),
        Obx(() => _SwitchRow(
          label: 'Mark as Disabled',
          subtitle: 'Student is physically disabled',
          value: _c.isDisabled.value,
          onChanged: (v) => _c.isDisabled.value = v,
          activeColor: const Color(0xFFD97706),
        )),
      ]),
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Obx(() => Column(children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _c.isSaving.value
                  ? null
                  : () async {
                      final ok = await _c.saveStudent();
                      if (ok && context.mounted) {
                        Get.back();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: _c.isSaving.value
                  ? sSavingIndicator()
                  : Icon(
                      _c.editingId.value != null
                          ? Icons.save_rounded
                          : Icons.person_add_rounded,
                      size: 20),
              label: Text(
                _c.editingId.value != null
                    ? 'Update Student'
                    : 'Save Student',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
          if (_c.editingId.value != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  _c.resetForm();
                  Get.back();
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ]));
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
                primary: Color(0xFF4F46E5))),
        child: child!,
      ),
    );
    if (picked != null) {
      _c.dobCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
}

// ── Reusable section card ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
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
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ]),
    );
  }
}

// ── Field block (label + input) ───────────────────────────────────────────────

class _FieldBlock extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel(label),
          const SizedBox(height: 6),
          child,
        ],
      );
}

// ── Switch row ────────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF111827))),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF6B7280))),
              ])),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ]),
      );
}
