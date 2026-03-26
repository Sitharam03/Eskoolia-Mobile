import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../controllers/role_controller.dart';
import '../../../core/routes/app_routes.dart';

class RolesView extends GetView<RoleController> {
  const RolesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Role Management',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 330, child: _buildFormCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildListCard()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return ListView(
      children: [
        _buildFormCard(),
        const SizedBox(height: 16),
        _buildListCard(),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  controller.editingRoleId.value != null ? 'Edit Role' : 'Add Role',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                )),
            const SizedBox(height: 16),
            Text(
              'NAME *',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Obx(() => ElevatedButton(
                      onPressed: controller.isSaving.value ? null : controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(controller.isSaving.value ? 'Saving...' : 'Save'),
                    )),
                const SizedBox(width: 8),
                Obx(() {
                  if (controller.editingRoleId.value != null) {
                    return OutlinedButton(
                      onPressed: controller.resetForm,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Role List',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 36,
                  child: TextField(
                    onChanged: (val) => controller.searchQuery.value = val,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredRoles.isEmpty) {
                return const Center(child: Text('No roles found.'));
              }
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                    columns: const [
                      DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: controller.filteredRoles.map((role) {
                      return DataRow(cells: [
                        DataCell(Text(role.name)),
                        DataCell(Text(role.isSystem ? 'System' : 'Custom')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Get.toNamed('${AppRoutes.assignPermission}/${role.id}');
                                },
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF7C3AED)),
                                child: const Text('Assign Permission'),
                              ),
                              TextButton(
                                onPressed: () => controller.startEdit(role),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF0EA5E9)),
                                child: const Text('Edit'),
                              ),
                              if (!role.isSystem)
                                TextButton(
                                  onPressed: () => controller.deleteRole(role.id),
                                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                                  child: const Text('Delete'),
                                ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
