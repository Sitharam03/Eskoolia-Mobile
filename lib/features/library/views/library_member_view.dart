import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/library_member_controller.dart';
import '../models/library_models.dart';
import '_library_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class LibraryMemberView extends StatelessWidget {
  const LibraryMemberView({super.key});

  LibraryMemberController get _c => Get.find<LibraryMemberController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Library',
      body: Column(
        children: [
          const LibraryNavTabs(activeRoute: AppRoutes.libraryMembers),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: _c.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatsRow(c: _c),
                      const SizedBox(height: 16),
                      _FormCard(c: _c),
                      Obx(() {
                        if (_c.errorMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ErrorBanner(msg: _c.errorMsg.value),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      const SizedBox(height: 20),
                      _MemberList(c: _c),
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

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final LibraryMemberController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = c.members.length;
      final students = c.members.where((m) => m.isStudent).length;
      final staff = c.members.where((m) => !m.isStudent).length;
      final active = c.members.where((m) => m.isActive).length;
      return Row(children: [
        _StatCard(
            value: '$total',
            label: 'Total',
            icon: Icons.badge_outlined,
            color: const Color(0xFF4F46E5)),
        const SizedBox(width: 8),
        _StatCard(
            value: '$students',
            label: 'Students',
            icon: Icons.school_rounded,
            color: const Color(0xFF0EA5E9)),
        const SizedBox(width: 8),
        _StatCard(
            value: '$staff',
            label: 'Staff',
            icon: Icons.person_rounded,
            color: const Color(0xFF8B5CF6)),
        const SizedBox(width: 8),
        _StatCard(
            value: '$active',
            label: 'Active',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF059669)),
      ]);
    });
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827))),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final LibraryMemberController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
                  border: const Border(
                      bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      c.editingId.value != null
                          ? Icons.edit_rounded
                          : Icons.person_add_rounded,
                      size: 18,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.editingId.value != null
                                ? 'Edit Member'
                                : 'Add New Member',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827)),
                          ),
                          Text(
                            c.editingId.value != null
                                ? 'Update member information'
                                : 'Register a student or staff member',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF9CA3AF)),
                          ),
                        ]),
                  ),
                  if (c.editingId.value != null)
                    GestureDetector(
                      onTap: c.cancelEdit,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Color(0xFF6B7280)),
                      ),
                    ),
                ]),
              ),

              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member Type toggle
                      sFieldLabel('Member Type'),
                      const SizedBox(height: 8),
                      _TypeToggle(c: c),
                      const SizedBox(height: 16),

                      // Person selector
                      if (c.memberType.value == 'student') ...[
                        sFieldLabel('Select Student *'),
                        const SizedBox(height: 6),
                        sDropdown<int>(
                          value: c.selectedStudentId.value,
                          hint: 'Choose a student',
                          items: c.students
                              .map((s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.displayLabel,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) => c.selectedStudentId.value = v,
                        ),
                      ] else ...[
                        sFieldLabel('Select Staff *'),
                        const SizedBox(height: 6),
                        sDropdown<int>(
                          value: c.selectedStaffId.value,
                          hint: 'Choose a staff member',
                          items: c.staffList
                              .map((s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.displayLabel,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (v) => c.selectedStaffId.value = v,
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Card Number
                      sFieldLabel('Library Card Number *'),
                      const SizedBox(height: 6),
                      sTextField(
                          controller: c.cardNoCtrl,
                          hint: 'e.g. LIB-2024-001'),
                      const SizedBox(height: 16),

                      // Active toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border:
                              Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Icon(
                            c.isActive.value
                                ? Icons.toggle_on_rounded
                                : Icons.toggle_off_rounded,
                            size: 22,
                            color: c.isActive.value
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Active Member',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF374151),
                                    fontWeight: FontWeight.w500)),
                          ),
                          Switch(
                            value: c.isActive.value,
                            onChanged: (v) => c.isActive.value = v,
                            activeColor: const Color(0xFF4F46E5),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: c.isSaving.value ? null : c.save,
                          icon: c.isSaving.value
                              ? sSavingIndicator()
                              : Icon(
                                  c.editingId.value != null
                                      ? Icons.update_rounded
                                      : Icons.person_add_rounded,
                                  size: 18),
                          label: Text(
                            c.isSaving.value
                                ? 'Saving…'
                                : (c.editingId.value != null
                                    ? 'Update Member'
                                    : 'Add Member'),
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          )),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final LibraryMemberController c;
  const _TypeToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        _TypeOption(
          label: 'Student',
          icon: Icons.school_rounded,
          selected: c.memberType.value == 'student',
          color: const Color(0xFF0EA5E9),
          onTap: () => c.setMemberType('student'),
        ),
        _TypeOption(
          label: 'Staff',
          icon: Icons.person_rounded,
          selected: c.memberType.value == 'staff',
          color: const Color(0xFF8B5CF6),
          onTap: () => c.setMemberType('staff'),
        ),
      ]),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeOption(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 4,
                        offset: const Offset(0, 1))
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? color : const Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Member List ───────────────────────────────────────────────────────────────

class _MemberList extends StatelessWidget {
  final LibraryMemberController c;
  const _MemberList({required this.c});

  @override
  Widget build(BuildContext context) {
    // ⚠️ Touch all three lists inside Obx so any of them changing triggers a rebuild
    return Obx(() {
      final members = c.members.toList();
      // Register students and staffList as Obx dependencies
      // so name lookups stay fresh even if they loaded after members
      final _ = c.students.length;
      final __ = c.staffList.length;

      if (members.isEmpty) {
        return sEmptyState('No members yet', Icons.badge_outlined);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              sectionHeader('Members'),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${members.length} registered',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...members.map((m) => _MemberCard(
              member: m,
              name: c.memberDisplayName(m),
              onEdit: () => c.startEdit(m),
              onDelete: () => showDialog(
                    context: context,
                    builder: (_) => sDeleteDialog(
                      context: context,
                      message: 'Delete member "${m.cardNo}"?',
                      onConfirm: () => c.delete(m.id),
                    ),
                  ))),
        ],
      );
    });
  }
}

class _MemberCard extends StatelessWidget {
  final LibraryMember member;
  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MemberCard(
      {required this.member,
      required this.name,
      required this.onEdit,
      required this.onDelete});

  Color get _typeColor =>
      member.isStudent ? const Color(0xFF0EA5E9) : const Color(0xFF8B5CF6);

  String get _initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Left accent strip — uniform color avoids borderRadius conflict
          Container(width: 4, color: _typeColor),

          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                // Avatar with gradient
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_typeColor, _typeColor.withValues(alpha: 0.65)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(_initials,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.credit_card_rounded,
                            size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(member.cardNo,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        sBadge(
                          member.isStudent ? 'Student' : 'Staff',
                          _typeColor,
                        ),
                        sBadge(
                          member.isActive ? 'Active' : 'Inactive',
                          member.isActive
                              ? const Color(0xFF059669)
                              : const Color(0xFF6B7280),
                        ),
                      ]),
                    ],
                  ),
                ),

                // Action buttons
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionBtn(
                      icon: Icons.edit_rounded,
                      color: const Color(0xFF0EA5E9),
                      onTap: onEdit,
                    ),
                    const SizedBox(height: 6),
                    _ActionBtn(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFDC2626),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: Color(0xFFDC2626), size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFFDC2626)))),
      ]),
    );
  }
}
