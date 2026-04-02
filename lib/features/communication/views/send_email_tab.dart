import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../students/views/_student_shared.dart';
import '../controllers/communication_controller.dart';

const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

class SendEmailTab extends StatelessWidget {
  const SendEmailTab({super.key});

  CommunicationController get _c => Get.find<CommunicationController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Send-to mode pills ──────────────────────────────────────────
          sectionHeader('Send Email'),
          const SizedBox(height: 14),
          sFieldLabel('Send To'),
          Obx(() => _buildModePills()),
          const SizedBox(height: 16),

          // ── Dynamic target selection ────────────────────────────────────
          Obx(() => _buildTargetSection()),
          const SizedBox(height: 16),

          // ── Recipient preview ───────────────────────────────────────────
          Obx(() => _buildTargetPreview()),
          const SizedBox(height: 16),

          // ── Title & description ─────────────────────────────────────────
          sFieldLabel('Email Title'),
          sTextField(controller: _c.emailTitleCtrl, hint: 'Subject line'),
          const SizedBox(height: 14),
          sFieldLabel('Email Description'),
          sTextField(
            controller: _c.emailDescCtrl,
            hint: 'Write your email content...',
            maxLines: 6,
          ),
          const SizedBox(height: 20),

          // ── Send button ─────────────────────────────────────────────────
          Obx(() => _gradientButton(
                label: _c.emailSending.value ? 'Sending...' : 'Send Email',
                icon: Icons.send_rounded,
                loading: _c.emailSending.value,
                onTap: _c.emailSending.value ? null : () => _c.sendEmail(),
              )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Mode toggle pills ──────────────────────────────────────────────────────

  Widget _buildModePills() {
    const modes = [
      {'key': 'group', 'label': 'Group', 'icon': Icons.groups_rounded},
      {'key': 'individual', 'label': 'Individual', 'icon': Icons.person_rounded},
      {'key': 'class', 'label': 'Class', 'icon': Icons.school_rounded},
    ];
    return Row(
      children: modes.map((m) {
        final active = _c.sendTo.value == m['key'];
        return Expanded(
          child: GestureDetector(
            onTap: () => _c.onSendToChanged(m['key'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: [_kPri, _kVio])
                    : null,
                color: active ? null : Colors.white.withValues(alpha: 0.7),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : _kPri.withValues(alpha: 0.15),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _kPri.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Icon(
                    m['icon'] as IconData,
                    size: 20,
                    color:
                        active ? Colors.white : _kPri.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color:
                          active ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Dynamic target section ─────────────────────────────────────────────────

  Widget _buildTargetSection() {
    switch (_c.sendTo.value) {
      case 'group':
        return _buildGroupTarget();
      case 'individual':
        return _buildIndividualTarget();
      case 'class':
        return _buildClassTarget();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGroupTarget() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel('Select Role / Group'),
          sDropdown<int>(
            value: _c.selectedRoleId.value,
            hint: 'Choose a role',
            items: _c.roles
                .map((r) =>
                    DropdownMenuItem(value: r.id, child: Text(r.name)))
                .toList(),
            onChanged: (v) => _c.selectedRoleId.value = v,
          ),
        ],
      );

  Widget _buildIndividualTarget() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel('Select Role to Filter Users'),
          sDropdown<int>(
            value: _c.selectedRoleId.value,
            hint: 'Choose a role first',
            items: _c.roles
                .map((r) =>
                    DropdownMenuItem(value: r.id, child: Text(r.name)))
                .toList(),
            onChanged: (v) {
              _c.selectedRoleId.value = v;
              if (v != null) _c.loadUsersForRole(v);
            },
          ),
          const SizedBox(height: 14),
          sFieldLabel('Select Users'),
          Obx(() {
            if (_c.usersLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _kPri),
                  ),
                ),
              );
            }
            if (_c.users.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: _kPri.withValues(alpha: 0.10)),
                ),
                child: Text(
                  _c.selectedRoleId.value == null
                      ? 'Select a role to see users'
                      : 'No users found for this role',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF9CA3AF)),
                ),
              );
            }
            return Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                border:
                    Border.all(color: _kPri.withValues(alpha: 0.12)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _c.users.length,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemBuilder: (_, i) {
                  final u = _c.users[i];
                  return Obx(() {
                    final sel = _c.selectedUsers.contains(u.id);
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: sel
                                ? [_kPri, _kVio]
                                : [
                                    _kPri.withValues(alpha: 0.1),
                                    _kVio.withValues(alpha: 0.05),
                                  ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          sel
                              ? Icons.check_rounded
                              : Icons.person_outline_rounded,
                          size: 16,
                          color: sel ? Colors.white : _kPri,
                        ),
                      ),
                      title: Text(u.name,
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: u.email != null
                          ? Text(u.email!,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF9CA3AF)))
                          : null,
                      onTap: () => sel
                          ? _c.selectedUsers.remove(u.id)
                          : _c.selectedUsers.add(u.id),
                    );
                  });
                },
              ),
            );
          }),
        ],
      );

  Widget _buildClassTarget() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sFieldLabel('Select Class'),
          sDropdown<int>(
            value: _c.selectedClassId.value,
            hint: 'Choose a class',
            items: _c.classes
                .map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) {
              _c.selectedClassId.value = v;
              if (v != null) _c.loadSectionsForClass(v);
            },
          ),
          const SizedBox(height: 14),
          sFieldLabel('Select Section (optional)'),
          Obx(() => sDropdown<int>(
                value: _c.selectedSectionId.value,
                hint: 'All sections',
                items: _c.sections
                    .map((s) =>
                        DropdownMenuItem(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => _c.selectedSectionId.value = v,
              )),
          const SizedBox(height: 14),
          sFieldLabel('Send To'),
          Obx(() => Row(
                children: ['students', 'parents'].map((t) {
                  final active = _c.targetStudentsOrParents.value == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _c.targetStudentsOrParents.value = t,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(
                                  colors: [_kPri, _kVio])
                              : null,
                          color: active
                              ? null
                              : Colors.white.withValues(alpha: 0.7),
                          border: Border.all(
                            color: active
                                ? Colors.transparent
                                : _kPri.withValues(alpha: 0.15),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            t[0].toUpperCase() + t.substring(1),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      );

  // ── Target preview ─────────────────────────────────────────────────────────

  Widget _buildTargetPreview() {
    String preview = '';
    if (_c.sendTo.value == 'group' && _c.selectedRoleId.value != null) {
      preview = 'Sending to all users in role: ${_c.roleName(_c.selectedRoleId.value!)}';
    } else if (_c.sendTo.value == 'individual' &&
        _c.selectedUsers.isNotEmpty) {
      preview = 'Sending to ${_c.selectedUsers.length} selected user(s)';
    } else if (_c.sendTo.value == 'class' &&
        _c.selectedClassId.value != null) {
      final cls =
          _c.classes.firstWhereOrNull((c) => c.id == _c.selectedClassId.value);
      final sec = _c.selectedSectionId.value != null
          ? _c.sections
              .firstWhereOrNull((s) => s.id == _c.selectedSectionId.value)
          : null;
      preview =
          'Sending to ${_c.targetStudentsOrParents.value} in ${cls?.name ?? 'class'}';
      if (sec != null) preview += ' - ${sec.name}';
    }

    if (preview.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kPri.withValues(alpha: 0.06),
            _kVio.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: _kPri.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (b) =>
                const LinearGradient(colors: [_kPri, _kVio]).createShader(b),
            child: const Icon(Icons.people_alt_rounded,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              preview,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient button ─────────────────────────────────────────────────────────

Widget _gradientButton({
  required String label,
  IconData? icon,
  bool loading = false,
  VoidCallback? onTap,
}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kPri, _kVio]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _kPri.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ],
                ),
        ),
      ),
    );
