import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../models/permission_model.dart';
import '../controllers/assign_permission_controller.dart';
import '../../../core/routes/app_routes.dart';

class AssignPermissionView extends GetView<AssignPermissionController> {
  const AssignPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Role Permission',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            Expanded(child: _buildTreeCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Obx(() {
              final roleName = controller.activeRoleName.value;
              return Text(
                'Assign Permission ${roleName != null ? '($roleName)' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              );
            }),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.roles),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back To Role'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: controller.selectedRoleId.value,
                          hint: const Text('Select Role'),
                          items: controller.roles.map((role) {
                            return DropdownMenuItem(
                              value: role.id,
                              child: Text(role.name),
                            );
                          }).toList(),
                          onChanged: controller.isLoadingRoles.value || controller.isSaving.value 
                              ? null 
                              : controller.onRoleChanged,
                        ),
                      ),
                    )),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton.icon(
                      onPressed: controller.selectedRoleId.value == null || controller.isLoadingTree.value || controller.isSaving.value
                          ? null
                          : controller.save,
                      icon: controller.isSaving.value
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save, size: 16),
                      label: Text(controller.isSaving.value ? 'Saving...' : 'Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTreeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Obx(() {
        if (controller.isLoadingTree.value && controller.modules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.modules.isEmpty) {
          return const Center(child: Text('No modules available for this role.'));
        }

        return Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine column count based on available width
                int crossAxisCount = 1;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 250, // Approx height for expanded items, though ExpansionTile usually prefers ListView
                  ),
                  itemCount: controller.modules.length,
                  itemBuilder: (context, index) {
                    final moduleRow = controller.modules[index];
                    return _buildModuleCard(moduleRow);
                  },
                );
              },
            ),
            if (controller.isSaving.value || controller.isLoadingTree.value)
              Container(
                color: Colors.white.withOpacity(0.6),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Processing...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildModuleCard(ModuleNode moduleRow) {
    final total = moduleRow.permissions.length;
    final checkedCount = moduleRow.permissions.where((p) => controller.selectedPermissionIds.contains(p.id)).length;
    final allChecked = total > 0 && checkedCount == total;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF7C3AED)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => controller.toggleModuleExpanded(moduleRow.module),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.prettyModuleName(moduleRow.module),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    controller.expandedModules[moduleRow.module] == true ? Icons.remove : Icons.add,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          // Body
          if (controller.expandedModules[moduleRow.module] == true)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$checkedCount/$total selected', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Row(
                          children: [
                            Checkbox(
                              value: allChecked,
                              onChanged: (val) => controller.toggleModule(moduleRow, val ?? false),
                              activeColor: const Color(0xFF7C3AED),
                            ),
                            const Text('Select all', style: TextStyle(fontSize: 13)),
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: moduleRow.permissions.length,
                        itemBuilder: (context, pIndex) {
                          final permission = moduleRow.permissions[pIndex];
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(permission.name, style: const TextStyle(fontSize: 13)),
                            value: controller.selectedPermissionIds.contains(permission.id),
                            onChanged: (_) => controller.togglePermission(permission.id),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: const Color(0xFF7C3AED),
                            dense: true,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
