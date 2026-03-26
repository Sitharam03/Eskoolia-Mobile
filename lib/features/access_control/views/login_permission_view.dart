import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../controllers/login_permission_controller.dart';
import '../../../core/routes/app_routes.dart';

class LoginPermissionView extends GetView<LoginPermissionController> {
  const LoginPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login Permission',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCriteriaCard(),
            const SizedBox(height: 16),
            Expanded(child: _buildTableCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaCard() {
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
                  'Select Criteria',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.toNamed(AppRoutes.roles),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Role'),
                    ),
                    OutlinedButton(
                      onPressed: () => Get.toNamed(AppRoutes.assignPermission),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Assign Permission'),
                    ),
                    OutlinedButton(
                      onPressed: () => Get.toNamed(AppRoutes.dueFeesLoginPermission),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Due Fees Login Permission'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final isStudent = controller.isStudentRole;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildDropdownField('Role *', controller.selectedRoleId, controller.roles),
                  if (isStudent) ...[
                    _buildDropdownField('Class *', controller.selectedClassId, controller.classes, onChanged: controller.onClassChanged),
                    _buildDropdownField('Section', controller.selectedSectionId, controller.filteredSections),
                    _buildTextField('Name', controller.nameController, 'Student name'),
                    _buildTextField('Roll No', controller.rollNoController, 'Roll no'),
                  ],
                ],
              );
            }),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isLoadingCriteria.value || controller.isLoading.value ? null : controller.searchUsers,
                    icon: controller.isLoading.value
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search, size: 16),
                    label: Text(controller.isLoading.value ? 'Searching...' : 'Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, RxnString rxValue, List<dynamic> items, {void Function(String?)? onChanged}) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: rxValue.value,
                hint: const Text('Select'),
                items: items.map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.name))).toList(),
                onChanged: (val) {
                  rxValue.value = val;
                  if (onChanged != null) onChanged(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController txtController, String hint) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: txtController,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return const Center(child: Text('No users found. Select role and click search.'));
        }

        final isStudent = controller.isStudentRole;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
              columns: isStudent
                  ? const [
                      DataColumn(label: Text('Admission')),
                      DataColumn(label: Text('Roll')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Class')),
                      DataColumn(label: Text('Student Perm')),
                      DataColumn(label: Text('Student Password')),
                      DataColumn(label: Text('Parent Perm')),
                      DataColumn(label: Text('Parent Password')),
                    ]
                  : const [
                      DataColumn(label: Text('Staff No')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Login Perm')),
                      DataColumn(label: Text('Password')),
                    ],
              rows: controller.users.map((row) {
                if (isStudent) {
                  final classNameStr = row.className != null ? '${row.className}${row.sectionName != null ? ' (${row.sectionName})' : ''}' : '-';
                  return DataRow(cells: [
                    DataCell(Text(row.admissionNo ?? '-')),
                    DataCell(Text(row.rollNo ?? '-')),
                    DataCell(Text(row.name)),
                    DataCell(Text(classNameStr)),
                    DataCell(
                      Checkbox(
                        value: row.accessStatus,
                        onChanged: controller.actionUserId.value == row.userId ? null : (v) => controller.toggleAccess(row.userId, v ?? false),
                      ),
                    ),
                    DataCell(_buildPasswordCell(row.userId)),
                    DataCell(
                      row.parentUserId != null
                          ? Checkbox(
                              value: row.parentAccessStatus ?? false,
                              onChanged: controller.actionUserId.value == row.parentUserId ? null : (v) => controller.toggleAccess(row.parentUserId!, v ?? false),
                            )
                          : const Text('Not linked', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    DataCell(row.parentUserId != null ? _buildPasswordCell(row.parentUserId!) : const Text('Not linked', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  ]);
                } else {
                  return DataRow(cells: [
                    DataCell(Text(row.staffNo ?? '-')),
                    DataCell(Text(row.name)),
                    DataCell(Text(row.roleName ?? '-')),
                    DataCell(Text(row.email ?? '-')),
                    DataCell(
                      Checkbox(
                        value: row.accessStatus,
                        onChanged: controller.actionUserId.value == row.userId ? null : (v) => controller.toggleAccess(row.userId, v ?? false),
                      ),
                    ),
                    DataCell(_buildPasswordCell(row.userId)),
                  ]);
                }
              }).toList(),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPasswordCell(int targetUserId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 30,
          child: TextField(
            onChanged: (val) => controller.passwordMap[targetUserId] = val,
            decoration: const InputDecoration(
              hintText: 'New pass',
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        OutlinedButton(
          onPressed: () => controller.resetPassword(targetUserId, false),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 30)),
          child: const Text('Update'),
        ),
        const SizedBox(width: 4),
        OutlinedButton(
          onPressed: () => controller.resetPassword(targetUserId, true),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 30)),
          child: const Text('Default'),
        ),
      ],
    );
  }
}
