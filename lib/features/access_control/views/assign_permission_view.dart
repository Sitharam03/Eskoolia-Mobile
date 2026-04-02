import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../models/permission_model.dart';
import '../controllers/assign_permission_controller.dart';
import '../../../core/routes/app_routes.dart';

class AssignPermissionView extends GetView<AssignPermissionController> {
  const AssignPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Assign Permission',
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Top card: role selector + save ──────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.roles),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 4),
                    Text('Back to Roles', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Role dropdown + save
          Obx(() => Row(
                children: [
                  // Role dropdown
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FF),
                        border: Border.all(color: const Color(0xFFE0E4EF)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: controller.selectedRoleId.value,
                          hint: Text('Select Role', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF))),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                          items: controller.roles.map((role) {
                            return DropdownMenuItem(
                              value: role.id,
                              child: Text(role.name, style: GoogleFonts.inter(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: controller.isLoadingRoles.value || controller.isSaving.value ? null : controller.onRoleChanged,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Save button
                  SizedBox(
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: controller.selectedRoleId.value == null || controller.isLoadingTree.value || controller.isSaving.value
                            ? null
                            : controller.save,
                        icon: controller.isSaving.value
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_rounded, size: 18),
                        label: Text(controller.isSaving.value ? 'Saving...' : 'Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          // Active role name
          Obx(() {
            final name = controller.activeRoleName.value;
            if (name == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, size: 14, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 4),
                  Text('Editing permissions for: $name',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF7C3AED), fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Module permission list ───────────────────────────────────────────────
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingTree.value && controller.modules.isEmpty) {
        return const SchoolLoader();
      }
      if (controller.modules.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/empty.png', width: 120, errorBuilder: (_, __, ___) => const Icon(Icons.lock_outline, size: 64, color: Colors.grey)),
              const SizedBox(height: 16),
              Text(
                controller.selectedRoleId.value == null ? 'Select a role to view permissions' : 'No modules available',
                style: GoogleFonts.inter(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: controller.modules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _buildModuleCard(controller.modules[i]),
          ),
          if (controller.isSaving.value || controller.isLoadingTree.value)
            Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const SchoolLoader(),
            ),
        ],
      );
    });
  }

  Widget _buildModuleCard(ModuleNode moduleRow) {
    return Obx(() {
      final total = moduleRow.permissions.length;
      final checkedCount = moduleRow.permissions.where((p) => controller.selectedPermissionIds.contains(p.id)).length;
      final allChecked = total > 0 && checkedCount == total;
      final isExpanded = controller.expandedModules[moduleRow.module] == true;

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFFCFCFF)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isExpanded ? const Color(0xFF7C3AED) : const Color(0xFFE0E4EF)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            // Module header — tappable
            InkWell(
              onTap: () => controller.toggleModuleExpanded(moduleRow.module),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(16),
                bottom: isExpanded ? Radius.zero : const Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: isExpanded
                      ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: isExpanded ? null : Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(15),
                    bottom: isExpanded ? Radius.zero : const Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isExpanded ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.apps_rounded, size: 18, color: isExpanded ? Colors.white : const Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.prettyModuleName(moduleRow.module),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isExpanded ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '$checkedCount / $total permissions',
                            style: TextStyle(fontSize: 11, color: isExpanded ? Colors.white70 : const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    ),
                    // Mini progress
                    if (!isExpanded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: checkedCount > 0 ? const Color(0xFFEDE9FE) : Colors.white,
                          border: checkedCount > 0 ? null : Border.all(color: const Color(0xFFE0E4EF)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$checkedCount/$total',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: checkedCount > 0 ? const Color(0xFF7C3AED) : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: isExpanded ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded permissions body
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Select all row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Permissions', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Text('Select All', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF7C3AED), fontWeight: FontWeight.w500)),
                            Transform.scale(
                              scale: 0.85,
                              child: Checkbox(
                                value: allChecked,
                                onChanged: (val) => controller.toggleModule(moduleRow, val ?? false),
                                activeColor: const Color(0xFF7C3AED),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 4),
                    // Permission items
                    ...moduleRow.permissions.map((permission) {
                      final isChecked = controller.selectedPermissionIds.contains(permission.id);
                      return InkWell(
                        onTap: () => controller.togglePermission(permission.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isChecked ? const Color(0xFFF5F3FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 0.85,
                                child: Checkbox(
                                  value: isChecked,
                                  onChanged: (_) => controller.togglePermission(permission.id),
                                  activeColor: const Color(0xFF7C3AED),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  permission.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isChecked ? const Color(0xFF5B21B6) : const Color(0xFF374151),
                                    fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isChecked) const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF7C3AED)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
