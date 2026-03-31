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
                return const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF4F46E5)),
                );
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
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
                _StatTile(
                  value: '$total',
                  label: 'Total Staff',
                  color: const Color(0xFF4F46E5),
                  icon: Icons.people_rounded,
                ),
                const SizedBox(width: 8),
                _StatTile(
                  value: '$active',
                  label: 'Active',
                  color: const Color(0xFF059669),
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatTile(
                  value: '$inactive',
                  label: 'Inactive',
                  color: const Color(0xFF9CA3AF),
                  icon: Icons.remove_circle_rounded,
                ),
                const SizedBox(width: 8),
                _StatTile(
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

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sSearchBar(
              hint: 'Search by name, staff no, email…',
              onChanged: (v) => c.searchQuery.value = v,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Status:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: HrStaffDirectoryController.statusFilters
                          .map(
                            (s) => Obx(
                              () => GestureDetector(
                                onTap: () =>
                                    c.selectedStatusFilter.value = s,
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: c.selectedStatusFilter
                                                .value ==
                                            s
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    s == 'all'
                                        ? 'All'
                                        : _capitalize(s),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: c.selectedStatusFilter
                                                  .value ==
                                              s
                                          ? Colors.white
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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

  Color get _statusColor {
    switch (staff.status) {
      case 'active':
        return const Color(0xFF059669);
      case 'inactive':
        return const Color(0xFF9CA3AF);
      case 'terminated':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: _statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4F46E5),
                                  Color(0xFF7C3AED),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              staff.initials,
                              style: GoogleFonts.inter(
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
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  staff.staffNo,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (staff.designationName
                                        .isNotEmpty)
                                      _InfoChip(
                                        staff.designationName,
                                        const Color(0xFF4F46E5),
                                      ),
                                    if (staff.designationName
                                            .isNotEmpty &&
                                        staff.departmentName.isNotEmpty)
                                      const SizedBox(width: 4),
                                    if (staff.departmentName.isNotEmpty)
                                      _InfoChip(
                                        staff.departmentName,
                                        const Color(0xFF8B5CF6),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ActionBtn(
                                icon: Icons.edit_rounded,
                                color: const Color(0xFF0EA5E9),
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            if (staff.email.isNotEmpty)
                              _ContactRow(
                                  Icons.email_outlined, staff.email),
                            if (staff.phone.isNotEmpty)
                              _ContactRow(
                                  Icons.phone_outlined, staff.phone),
                            sBadge(
                              staff.status == 'active'
                                  ? 'Active'
                                  : staff.status == 'terminated'
                                      ? 'Terminated'
                                      : 'Inactive',
                              staff.status == 'active'
                                  ? const Color(0xFF059669)
                                  : staff.status == 'terminated'
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );
}

// ── Contact Row ───────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
        sectionHeader(title),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:
                const Color(0xFF4F46E5).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count records',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF4F46E5),
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
