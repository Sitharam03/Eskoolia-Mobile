import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_staff_directory_controller.dart';
import '../controllers/hr_staff_controller.dart';
import '../models/hr_models.dart';
import '_hr_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

// ── Design Constants ─────────────────────────────────────────────────────────

const _kPri = Color(0xFF0EA5E9);
const _kSec = Color(0xFF0284C7);
const _kVio = Color(0xFF6366F1);

Color _accentFor(String name) {
  if (name.isEmpty) return _kPri;
  final code = name.codeUnitAt(0) % 6;
  const palette = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF7C3AED),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];
  return palette[code];
}

// ── Helper ────────────────────────────────────────────────────────────────────

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

// ── View ──────────────────────────────────────────────────────────────────────

class HrStaffDirectoryView extends StatelessWidget {
  const HrStaffDirectoryView({super.key});

  HrStaffDirectoryController get c =>
      Get.find<HrStaffDirectoryController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Human Resource',
      body: Column(
        children: [
          const HrNavTabs(activeRoute: AppRoutes.hrStaffDirectory),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                color: _kPri,
                onRefresh: c.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatsGrid(c: c),
                      const SizedBox(height: 14),
                      _FilterBar(c: c),
                      const SizedBox(height: 14),
                      _StaffList(c: c),
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

// ── Stats Grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final HrStaffDirectoryController c;
  const _StatsGrid({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final total = c.staff.length;
        final active =
            c.staff.where((s) => s.status == 'active').length;
        final inactive =
            c.staff.where((s) => s.status == 'inactive').length;
        final terminated =
            c.staff.where((s) => s.status == 'terminated').length;

        return Column(
          children: [
            Row(
              children: [
                _Stat(
                  value: '$total',
                  label: 'Total Staff',
                  color: _kVio,
                  icon: Icons.people_rounded,
                ),
                const SizedBox(width: 8),
                _Stat(
                  value: '$active',
                  label: 'Active',
                  color: const Color(0xFF22C55E),
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Stat(
                  value: '$inactive',
                  label: 'Inactive',
                  color: const Color(0xFF9CA3AF),
                  icon: Icons.remove_circle_rounded,
                ),
                const SizedBox(width: 8),
                _Stat(
                  value: '$terminated',
                  label: 'Terminated',
                  color: const Color(0xFFDC2626),
                  icon: Icons.block_rounded,
                ),
              ],
            ),
          ],
        );
      });
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withValues(alpha: 0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final HrStaffDirectoryController c;
  const _FilterBar({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, _kPri.withValues(alpha: 0.03)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: _kPri.withValues(alpha: 0.10)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kPri.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sSearchBar(
              hint: 'Search by name, staff no, email...',
              onChanged: (v) => c.searchQuery.value = v,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: HrStaffDirectoryController.statusFilters
                    .map(
                      (s) => Obx(
                        () {
                          final isActive =
                              c.selectedStatusFilter.value == s;
                          return GestureDetector(
                            onTap: () =>
                                c.selectedStatusFilter.value = s,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: isActive
                                    ? const LinearGradient(
                                        colors: [_kPri, _kVio],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      )
                                    : null,
                                color: isActive ? null : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: isActive
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: _kPri
                                              .withValues(alpha: 0.30),
                                          blurRadius: 8,
                                          offset:
                                              const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                s == 'all'
                                    ? 'All'
                                    : _capitalize(s),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => sDropdown<int>(
                value: c.selectedDeptFilter.value,
                hint: 'All Departments',
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('All Departments'),
                  ),
                  ...c.departments.map(
                    (d) => DropdownMenuItem<int>(
                      value: d.id,
                      child: Text(d.name),
                    ),
                  ),
                ],
                onChanged: (v) => c.selectedDeptFilter.value = v,
              ),
            ),
          ],
        ),
      );
}

// ── Staff List ────────────────────────────────────────────────────────────────

class _StaffList extends StatelessWidget {
  final HrStaffDirectoryController c;
  const _StaffList({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        // touch reactive lists for full reactivity
        final _ = c.staff.length;
        final __ = c.departments.length;
        final items = c.filtered;

        if (items.isEmpty) {
          return sEmptyState(
              'No staff members found', Icons.people_outline_rounded);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ListHeader(title: 'Staff Members', count: items.length),
            const SizedBox(height: 10),
            ...items.map((s) => _StaffCard(staff: s, c: c)),
          ],
        );
      });
}

// ── Staff Card ────────────────────────────────────────────────────────────────

class _StaffCard extends StatelessWidget {
  final Staff staff;
  final HrStaffDirectoryController c;
  const _StaffCard({required this.staff, required this.c});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(staff.fullName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, accent.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative circle bottom-right
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar with gradient and glow
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent, accent.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        staff.initials,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            staff.staffNo,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionBtn(
                          icon: Icons.edit_rounded,
                          color: _kPri,
                          onTap: () {
                            Get.find<HrStaffController>()
                                .startEdit(staff);
                            Get.toNamed(AppRoutes.hrStaff);
                          },
                        ),
                        const SizedBox(height: 6),
                        _ActionBtn(
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFDC2626),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => sDeleteDialog(
                              context: context,
                              message:
                                  'Delete "${staff.fullName}"?',
                              onConfirm: () =>
                                  c.delete(staff.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Info chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (staff.designationName.isNotEmpty)
                      _InfoChip(
                        label: staff.designationName,
                        color: _kVio,
                        icon: Icons.badge_rounded,
                      ),
                    if (staff.departmentName.isNotEmpty)
                      _InfoChip(
                        label: staff.departmentName,
                        color: _kPri,
                        icon: Icons.business_rounded,
                      ),
                    _InfoChip(
                      label: staff.status == 'active'
                          ? 'Active'
                          : staff.status == 'terminated'
                              ? 'Terminated'
                              : 'Inactive',
                      color: staff.status == 'active'
                          ? const Color(0xFF22C55E)
                          : staff.status == 'terminated'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF9CA3AF),
                      icon: staff.status == 'active'
                          ? Icons.check_circle_rounded
                          : staff.status == 'terminated'
                              ? Icons.block_rounded
                              : Icons.remove_circle_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Contact info row
                Row(
                  children: [
                    if (staff.email.isNotEmpty) ...[
                      Icon(Icons.email_outlined,
                          size: 13,
                          color: accent.withValues(alpha: 0.50)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          staff.email,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (staff.email.isNotEmpty &&
                        staff.phone.isNotEmpty)
                      const SizedBox(width: 12),
                    if (staff.phone.isNotEmpty) ...[
                      Icon(Icons.phone_outlined,
                          size: 13,
                          color: accent.withValues(alpha: 0.50)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          staff.phone,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _InfoChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.10),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}

// ── List Header ───────────────────────────────────────────────────────────────

class _ListHeader extends StatelessWidget {
  final String title;
  final int count;
  const _ListHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kPri.withValues(alpha: 0.10),
                _kVio.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kPri.withValues(alpha: 0.12)),
          ),
          child: Text(
            '$count records',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _kPri,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]);
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.10),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: color),
        ),
      );
}
