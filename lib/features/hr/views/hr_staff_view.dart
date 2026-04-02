import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_staff_controller.dart';
import '_hr_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colour tokens
// ─────────────────────────────────────────────────────────────────────────────

const _kPrimary  = Color(0xFF4F46E5);
const _kPurple   = Color(0xFF7C3AED);
const _kSuccess  = Color(0xFF059669);
const _kDanger   = Color(0xFFDC2626);
const _kInfo     = Color(0xFF0EA5E9);
const _kOrange   = Color(0xFFEA580C);
const _kViolet   = Color(0xFF8B5CF6);
const _kPink     = Color(0xFFE1306C);

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// 2-column row that stacks to 1 column on screens narrower than 360 dp.
Widget _row2(BuildContext context, Widget left, Widget right) {
  final w = MediaQuery.of(context).size.width - 32;
  if (w >= 310) {
    return Row(children: [
      Expanded(child: left),
      const SizedBox(width: 12),
      Expanded(child: right),
    ]);
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [left, const SizedBox(height: 14), right],
  );
}

Future<void> _pickDate(BuildContext ctx, TextEditingController ctrl) async {
  DateTime initial = DateTime.now();
  if (ctrl.text.isNotEmpty) {
    try { initial = DateTime.parse(ctrl.text); } catch (_) {}
  }
  final picked = await showDatePicker(
    context: ctx,
    initialDate: initial,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
    builder: (c, child) => Theme(
      data: Theme.of(c).copyWith(
        colorScheme: const ColorScheme.light(
          primary: _kPrimary,
          onPrimary: Colors.white,
          onSurface: Color(0xFF111827),
        ),
      ),
      child: child!,
    ),
  );
  if (picked != null) {
    ctrl.text =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main View
// ─────────────────────────────────────────────────────────────────────────────

class HrStaffView extends StatelessWidget {
  const HrStaffView({super.key});

  HrStaffController get c => Get.find<HrStaffController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Human Resource',
      body: Column(children: [
        const HrNavTabs(activeRoute: AppRoutes.hrStaff),
        Expanded(
          child: Obx(() {
            if (c.isLoading.value) {
              return const SchoolLoader();
            }
            return RefreshIndicator(
              color: _kPrimary,
              onRefresh: c.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PageHeader(c: c),
                    const SizedBox(height: 16),
                    _sectionHeader('1', 'Basic Information',
                        Icons.person_rounded, _kPrimary),
                    const SizedBox(height: 8),
                    _BasicInfoCard(c: c),
                    const SizedBox(height: 16),
                    _sectionHeader('2', 'Employment Details',
                        Icons.work_rounded, _kInfo),
                    const SizedBox(height: 8),
                    _EmploymentCard(c: c),
                    const SizedBox(height: 16),
                    _sectionHeader('3', 'Leave Allocation',
                        Icons.event_available_rounded, _kSuccess),
                    const SizedBox(height: 8),
                    _LeaveCard(c: c),
                    const SizedBox(height: 16),
                    _sectionHeader('4', 'Bank Details',
                        Icons.account_balance_rounded, _kOrange),
                    const SizedBox(height: 8),
                    _BankCard(c: c),
                    const SizedBox(height: 16),
                    _sectionHeader('5', 'Social Media',
                        Icons.share_rounded, _kPink),
                    const SizedBox(height: 8),
                    _SocialCard(c: c),
                    const SizedBox(height: 16),
                    _sectionHeader('6', 'Document Info',
                        Icons.folder_open_rounded, _kViolet),
                    const SizedBox(height: 8),
                    _DocumentCard(c: c),
                    const SizedBox(height: 16),
                    Obx(() => c.errorMsg.value.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ErrorBanner(msg: c.errorMsg.value),
                          )
                        : const SizedBox.shrink()),
                    _ActionRow(c: c),
                  ],
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

Widget _sectionHeader(
    String number, String title, IconData icon, Color color) {
  return Row(children: [
    Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        number,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
    const SizedBox(width: 10),
    Icon(icon, size: 18, color: color),
    const SizedBox(width: 6),
    Expanded(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
        ),
      ),
    ),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Header
// ─────────────────────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  final HrStaffController c;
  const _PageHeader({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final isEditing = c.editingId.value != null;
        final name = c.firstNameCtrl.text;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPrimary, _kPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Icon(
                isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing
                        ? 'Edit: ${name.isNotEmpty ? name : 'Staff Member'}'
                        : 'Add New Staff Member',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEditing
                        ? 'Update staff information below'
                        : 'Fill in all details to create a new staff record',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  if (c.staffNoCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Staff No: ${c.staffNoCtrl.text}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ]),
        );
      });
}

// ─────────────────────────────────────────────────────────────────────────────
// 1 · Basic Information
// ─────────────────────────────────────────────────────────────────────────────

class _BasicInfoCard extends StatelessWidget {
  final HrStaffController c;
  const _BasicInfoCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Staff No + Status
                _row2(
                  context,
                  _field('Staff No', sTextField(
                    controller: c.staffNoCtrl,
                    hint: 'Auto-generated',
                    readOnly: true,
                  )),
                  _field('Status', sDropdown<String>(
                    value: HrStaffController.statusOptions
                            .contains(c.selectedStatus.value)
                        ? c.selectedStatus.value
                        : null,
                    hint: 'Select status',
                    items: HrStaffController.statusOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(_cap(s),
                                  style: _dropStyle),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) c.selectedStatus.value = v;
                    },
                  )),
                ),
                const SizedBox(height: 14),

                // First + Last name
                _row2(
                  context,
                  _field('First Name *', sTextField(
                    controller: c.firstNameCtrl,
                    hint: 'First name',
                  )),
                  _field('Last Name', sTextField(
                    controller: c.lastNameCtrl,
                    hint: 'Last name',
                  )),
                ),
                const SizedBox(height: 14),

                // Email + Phone
                _row2(
                  context,
                  _field('Email *', sTextField(
                    controller: c.emailCtrl,
                    hint: 'email@example.com',
                    keyboardType: TextInputType.emailAddress,
                  )),
                  _field('Phone', sTextField(
                    controller: c.phoneCtrl,
                    hint: 'Phone number',
                    keyboardType: TextInputType.phone,
                  )),
                ),
                const SizedBox(height: 14),

                // DOB + Join Date
                _row2(
                  context,
                  _field('Date of Birth', sTextField(
                    controller: c.dobCtrl,
                    hint: 'YYYY-MM-DD',
                    readOnly: true,
                    onTap: () => _pickDate(context, c.dobCtrl),
                    suffixIcon: const Icon(Icons.calendar_today_rounded,
                        size: 16, color: Color(0xFF9CA3AF)),
                  )),
                  _field('Join Date *', sTextField(
                    controller: c.joinDateCtrl,
                    hint: 'YYYY-MM-DD',
                    readOnly: true,
                    onTap: () => _pickDate(context, c.joinDateCtrl),
                    suffixIcon: const Icon(Icons.calendar_today_rounded,
                        size: 16, color: Color(0xFF9CA3AF)),
                  )),
                ),
                const SizedBox(height: 14),

                // Gender + Marital Status
                _row2(
                  context,
                  _field('Gender', sDropdown<String>(
                    value: HrStaffController.genderOptions
                            .contains(c.selectedGender.value)
                        ? c.selectedGender.value
                        : null,
                    hint: 'Select gender',
                    items: HrStaffController.genderOptions
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(_cap(g), style: _dropStyle),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) c.selectedGender.value = v;
                    },
                  )),
                  _field('Marital Status', sDropdown<String>(
                    value: HrStaffController.maritalOptions
                            .contains(c.selectedMaritalStatus.value)
                        ? c.selectedMaritalStatus.value
                        : null,
                    hint: 'Select status',
                    items: HrStaffController.maritalOptions
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(_cap(m), style: _dropStyle),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) c.selectedMaritalStatus.value = v;
                    },
                  )),
                ),
                const SizedBox(height: 14),

                // Role + Department
                _row2(
                  context,
                  _field('Role', sDropdown<int>(
                    value: c.selectedRoleId.value,
                    hint: 'Select role',
                    items: c.roles
                        .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name,
                                  style: _dropStyle,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => c.selectedRoleId.value = v,
                  )),
                  _field('Department', sDropdown<int>(
                    value: c.selectedDepartmentId.value,
                    hint: 'Select dept.',
                    items: c.departments
                        .map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text(d.name,
                                  style: _dropStyle,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) {
                      c.selectedDepartmentId.value = v;
                      c.selectedDesignationId.value = null;
                    },
                  )),
                ),
                const SizedBox(height: 14),

                // Designation (full width, filtered)
                _field('Designation', sDropdown<int>(
                  value: c.selectedDesignationId.value,
                  hint: 'Select designation',
                  items: c.filteredDesignations
                      .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name,
                                style: _dropStyle,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => c.selectedDesignationId.value = v,
                )),
                const SizedBox(height: 14),

                // Father + Mother
                _row2(
                  context,
                  _field("Father's Name", sTextField(
                    controller: c.fathersNameCtrl,
                    hint: "Father's name",
                  )),
                  _field("Mother's Name", sTextField(
                    controller: c.mothersNameCtrl,
                    hint: "Mother's name",
                  )),
                ),
                const SizedBox(height: 14),

                // Emergency Mobile + Driving License
                _row2(
                  context,
                  _field('Emergency Mobile', sTextField(
                    controller: c.emergencyMobileCtrl,
                    hint: 'Emergency contact',
                    keyboardType: TextInputType.phone,
                  )),
                  _field('Driving License', sTextField(
                    controller: c.drivingLicenseCtrl,
                    hint: 'License number',
                  )),
                ),
                const SizedBox(height: 14),

                // Current Address
                _field('Current Address', sTextField(
                  controller: c.currentAddressCtrl,
                  hint: 'Current residential address',
                  maxLines: 2,
                )),
                const SizedBox(height: 14),

                // Permanent Address
                _field('Permanent Address', sTextField(
                  controller: c.permanentAddressCtrl,
                  hint: 'Permanent address',
                  maxLines: 2,
                )),
                const SizedBox(height: 14),

                // Qualification + Experience
                _row2(
                  context,
                  _field('Qualification', sTextField(
                    controller: c.qualificationCtrl,
                    hint: 'e.g. BSc Computer Science',
                  )),
                  _field('Experience', sTextField(
                    controller: c.experienceCtrl,
                    hint: 'e.g. 5 years',
                  )),
                ),
              ],
            )),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2 · Employment Details
// ─────────────────────────────────────────────────────────────────────────────

class _EmploymentCard extends StatelessWidget {
  final HrStaffController c;
  const _EmploymentCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Salary + Contract Type
                _row2(
                  context,
                  _field('Basic Salary', sTextField(
                    controller: c.basicSalaryCtrl,
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  )),
                  _field('Contract Type', sDropdown<String>(
                    value: HrStaffController.contractOptions
                            .contains(c.selectedContractType.value)
                        ? c.selectedContractType.value
                        : null,
                    hint: 'Select type',
                    items: HrStaffController.contractOptions
                        .map((ct) => DropdownMenuItem(
                              value: ct,
                              child: Text(_cap(ct), style: _dropStyle),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) c.selectedContractType.value = v;
                    },
                  )),
                ),
                const SizedBox(height: 14),

                // EPF No + Location
                _row2(
                  context,
                  _field('EPF No', sTextField(
                    controller: c.epfNoCtrl,
                    hint: 'EPF number',
                  )),
                  _field('Location', sTextField(
                    controller: c.locationCtrl,
                    hint: 'Work location',
                  )),
                ),
                const SizedBox(height: 14),

                // Show Public Toggle
                _ToggleTile(
                  value: c.showPublic.value,
                  onChanged: (v) => c.showPublic.value = v,
                  icon: c.showPublic.value
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  title: 'Show in Public Directory',
                  subtitle: 'Staff member appears in the public directory',
                  activeColor: _kPrimary,
                ),
              ],
            )),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 3 · Leave Allocation
// ─────────────────────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  final HrStaffController c;
  const _LeaveCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _row2(
            context,
            _field('Casual Leave (days)', sTextField(
              controller: c.casualLeaveCtrl,
              hint: '0',
              keyboardType: TextInputType.number,
            )),
            _field('Medical Leave (days)', sTextField(
              controller: c.medicalLeaveCtrl,
              hint: '0',
              keyboardType: TextInputType.number,
            )),
          ),
          const SizedBox(height: 14),
          _field('Maternity Leave (days)', sTextField(
            controller: c.maternityLeaveCtrl,
            hint: '0',
            keyboardType: TextInputType.number,
          )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4 · Bank Details
// ─────────────────────────────────────────────────────────────────────────────

class _BankCard extends StatelessWidget {
  final HrStaffController c;
  const _BankCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row2(
              context,
              _field('Account Name', sTextField(
                controller: c.bankAccountNameCtrl,
                hint: 'Account holder name',
              )),
              _field('Account No', sTextField(
                controller: c.bankAccountNoCtrl,
                hint: 'Account number',
                keyboardType: TextInputType.number,
              )),
            ),
            const SizedBox(height: 14),
            _row2(
              context,
              _field('Bank Name', sTextField(
                controller: c.bankNameCtrl,
                hint: 'Bank name',
              )),
              _field('Branch Name', sTextField(
                controller: c.bankBranchCtrl,
                hint: 'Branch name',
              )),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 5 · Social Media
// ─────────────────────────────────────────────────────────────────────────────

class _SocialCard extends StatelessWidget {
  final HrStaffController c;
  const _SocialCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SocialField(
              label: 'Facebook',
              controller: c.facebookCtrl,
              hint: 'https://facebook.com/username',
              icon: Icons.facebook_rounded,
              iconColor: const Color(0xFF1877F2),
            ),
            const SizedBox(height: 14),
            _SocialField(
              label: 'Twitter / X',
              controller: c.twitterCtrl,
              hint: 'https://twitter.com/username',
              icon: Icons.alternate_email_rounded,
              iconColor: const Color(0xFF1DA1F2),
            ),
            const SizedBox(height: 14),
            _SocialField(
              label: 'LinkedIn',
              controller: c.linkedinCtrl,
              hint: 'https://linkedin.com/in/username',
              icon: Icons.work_outline_rounded,
              iconColor: const Color(0xFF0A66C2),
            ),
            const SizedBox(height: 14),
            _SocialField(
              label: 'Instagram',
              controller: c.instagramCtrl,
              hint: 'https://instagram.com/username',
              icon: Icons.camera_alt_rounded,
              iconColor: _kPink,
            ),
          ],
        ),
      );
}

class _SocialField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  const _SocialField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel(label),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            style: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF9CA3AF)),
              prefixIcon: Container(
                width: 40,
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 13),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: _kPrimary, width: 1.5),
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 6 · Document Info
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  final HrStaffController c;
  const _DocumentCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _kViolet.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _kViolet.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: _kViolet),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Upload staff documents. Accepted: PDF, DOC, JPG, PNG.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 14),

            _DocTile(
              label: 'Staff Photo',
              subLabel: 'Profile picture (JPG, PNG)',
              icon: Icons.photo_camera_rounded,
              iconColor: _kViolet,
              fieldKey: 'staffPhoto',
              c: c,
            ),
            const SizedBox(height: 12),
            _DocTile(
              label: 'Resume / CV',
              subLabel: 'PDF or DOC format',
              icon: Icons.description_rounded,
              iconColor: _kInfo,
              fieldKey: 'resume',
              c: c,
            ),
            const SizedBox(height: 12),
            _DocTile(
              label: 'Joining Letter',
              subLabel: 'Official joining document',
              icon: Icons.article_rounded,
              iconColor: _kSuccess,
              fieldKey: 'joiningLetter',
              c: c,
            ),
            const SizedBox(height: 12),
            _DocTile(
              label: 'Other Documents',
              subLabel: 'Any additional documents',
              icon: Icons.folder_rounded,
              iconColor: _kOrange,
              fieldKey: 'otherDoc',
              c: c,
            ),
          ],
        ),
      );
}

class _DocTile extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final Color iconColor;
  final String fieldKey;
  final HrStaffController c;

  const _DocTile({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.iconColor,
    required this.fieldKey,
    required this.c,
  });

  String get _localPath {
    switch (fieldKey) {
      case 'staffPhoto':    return c.staffPhotoLocal.value;
      case 'resume':        return c.resumeLocal.value;
      case 'joiningLetter': return c.joiningLetterLocal.value;
      case 'otherDoc':      return c.otherDocLocal.value;
      default:              return '';
    }
  }

  String get _serverPath {
    switch (fieldKey) {
      case 'staffPhoto':    return c.staffPhotoServer.value;
      case 'resume':        return c.resumeServer.value;
      case 'joiningLetter': return c.joiningLetterServer.value;
      case 'otherDoc':      return c.otherDocServer.value;
      default:              return '';
    }
  }

  String get _displayName {
    switch (fieldKey) {
      case 'staffPhoto':    return c.staffPhotoName.value;
      case 'resume':        return c.resumeName.value;
      case 'joiningLetter': return c.joiningLetterName.value;
      case 'otherDoc':      return c.otherDocName.value;
      default:              return '';
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
        final hasLocal  = _localPath.isNotEmpty;
        final hasServer = _serverPath.isNotEmpty;
        final hasAny    = hasLocal || hasServer;
        final fileName  = _displayName;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasAny
                ? iconColor.withValues(alpha: 0.05)
                : const Color(0xFFF9FAFB),
            border: Border.all(
              color: hasAny
                  ? iconColor.withValues(alpha: 0.35)
                  : const Color(0xFFE5E7EB),
              width: hasAny ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: hasAny ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),

            // Label + filename
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (hasAny && fileName.isNotEmpty)
                    Row(children: [
                      Icon(Icons.check_circle_rounded,
                          size: 12, color: iconColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fileName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasServer && !hasLocal)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Saved',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: iconColor),
                          ),
                        ),
                    ])
                  else
                    Text(
                      subLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Clear new pick button (only shown when local file picked)
            if (hasLocal) ...[
              GestureDetector(
                onTap: () => c.clearFile(fieldKey),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _kDanger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: _kDanger),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Upload / Change button
            GestureDetector(
              onTap: () => c.pickFile(fieldKey),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.upload_file_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    hasAny ? 'Change' : 'Upload',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        );
      });
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Row
// ─────────────────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final HrStaffController c;
  const _ActionRow({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final isEditing = c.editingId.value != null;
        final isSaving  = c.isSaving.value;
        return Column(children: [
          if (isEditing) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: isSaving
                    ? null
                    : () {
                        c.cancelEdit();
                        Get.back();
                      },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(
                  'Cancel Edit',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                  side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : c.save,
              icon: isSaving
                  ? sSavingIndicator()
                  : Icon(
                      isEditing
                          ? Icons.update_rounded
                          : Icons.save_rounded,
                      size: 20),
              label: Text(
                isSaving
                    ? 'Saving…'
                    : isEditing
                        ? 'Update Staff'
                        : 'Save Staff Member',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _kPrimary.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ]);
      });
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Banner
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kDanger.withValues(alpha: 0.08),
          border:
              Border.all(color: _kDanger.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          const Icon(Icons.error_rounded, size: 18, color: _kDanger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle Tile
// ─────────────────────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color activeColor;

  const _ToggleTile({
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? activeColor.withValues(alpha: 0.05)
              : const Color(0xFFF9FAFB),
          border: Border.all(
            color: value
                ? activeColor.withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon,
              size: 20,
              color: value ? activeColor : const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    )),
                Text(subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                    )),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Micro helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps a widget with a labelled field column.
Widget _field(String label, Widget input) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sFieldLabel(label),
        const SizedBox(height: 6),
        input,
      ],
    );

final _dropStyle =
    GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827));
