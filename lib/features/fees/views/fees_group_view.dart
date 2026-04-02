import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/fees_group_controller.dart';
import '../models/fees_group_model.dart';
import '_fees_nav_tabs.dart';
import '_fees_shared.dart';
import '../../../core/widgets/school_loader.dart';

class FeesGroupView extends StatelessWidget {
  const FeesGroupView({super.key});

  FeesGroupController get _c => Get.find<FeesGroupController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Fees Groups',
      body: Column(
        children: [
          const FeesNavTabs(activeRoute: AppRoutes.feesGroups),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value && _c.groups.isEmpty) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                onRefresh: _c.loadAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildFilterBar(context),
                      const SizedBox(height: 8),
                      _buildList(context),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kFeesPrimary,
        foregroundColor: Colors.white,
        onPressed: () {
          _c.startCreate();
          _showSheet(context, isEdit: false);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: fCardDecoration(),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: fDropdown<int?>(
                  hint: 'All Years',
                  value: _c.filterYearId.value,
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Years')),
                    ..._c.academicYears.map((y) => DropdownMenuItem(
                        value: y.id, child: Text(y.title))),
                  ],
                  onChanged: (v) => _c.filterYearId.value = v,
                ),
              ),
              const SizedBox(width: 10),
              fActionBtn(Icons.refresh, kFeesPrimary, _c.loadAll),
            ],
          )),
    );
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      final list = _c.filtered;
      if (list.isEmpty) {
        return fEmptyState('No fee groups found.\nTap + to add one.',
            icon: Icons.category_outlined);
      }
      return Column(
        children: list
            .map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GroupCard(
                    group: g,
                    yearName: _c.yearName(g.academicYear),
                    onEdit: () {
                      _c.startEdit(g);
                      _showSheet(context, isEdit: true);
                    },
                    onDelete: () => fDeleteDialog(
                      context,
                      'Delete fee group "${g.name}"? This cannot be undone.',
                      () => _c.deleteGroup(g.id),
                    ),
                  ),
                ))
            .toList(),
      );
    });
  }

  void _showSheet(BuildContext context, {required bool isEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _GroupFormSheet(
          controller: _c, isEdit: isEdit),
    );
  }
}

// ── Group card ─────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final FeesGroup group;
  final String yearName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.yearName,
    required this.onEdit,
    required this.onDelete,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: fCardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        fActiveBadge(group.isActive),
                      ],
                    ),
                    if (group.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        group.description,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF6B7280)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(Icons.calendar_today_outlined, yearName,
                            const Color(0xFF6366F1)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        fActionBtn(
                            Icons.edit_outlined, kFeesPrimary, onEdit),
                        const SizedBox(width: 8),
                        fActionBtn(
                            Icons.delete_outline, kFeesRed, onDelete),
                      ],
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

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color)),
          ],
        ),
      );
}

// ── Group form sheet ───────────────────────────────────────────────────────────

class _GroupFormSheet extends StatelessWidget {
  final FeesGroupController controller;
  final bool isEdit;

  const _GroupFormSheet(
      {required this.controller, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            isEdit ? 'Edit Fee Group' : 'Add Fee Group',
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Academic Year
          fLabel('Academic Year *'),
          Obx(() => fDropdown<int?>(
                hint: 'Select year',
                value: controller.formYearId.value,
                items: controller.academicYears
                    .map((y) => DropdownMenuItem(
                        value: y.id as int?, child: Text(y.title)))
                    .toList(),
                onChanged: (v) => controller.formYearId.value = v,
              )),
          const SizedBox(height: 14),

          // Name
          fLabel('Group Name *'),
          fTextField(controller.nameCtrl, 'e.g. Tuition Fees'),
          const SizedBox(height: 14),

          // Description
          fLabel('Description'),
          fTextField(controller.descCtrl, 'Optional description',
              maxLines: 2),
          const SizedBox(height: 14),

          // Active toggle
          Obx(() => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text('Active',
                    style: GoogleFonts.inter(fontSize: 14)),
                value: controller.formIsActive.value,
                activeColor: kFeesPrimary,
                onChanged: (v) => controller.formIsActive.value = v,
              )),
          const SizedBox(height: 6),

          Obx(() => fPrimaryBtn(
                label: isEdit ? 'Update Group' : 'Create Group',
                loading: controller.isLoading.value,
                onPressed: controller.saveGroup,
              )),
        ],
      ),
    );
  }
}
