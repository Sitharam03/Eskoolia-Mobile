import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../controllers/due_fees_permission_controller.dart';
import '../../../core/routes/app_routes.dart';

class DueFeesLoginPermissionView extends GetView<DueFeesPermissionController> {
  const DueFeesLoginPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Due Fees Login Permission',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text(
                      'Due Fees Login Permission',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage login blocking for users with fee dues.',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
                    ),
                  ],
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
                      onPressed: () => Get.toNamed(AppRoutes.loginPermission),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Login Permission'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildDropdownField('Class', controller.selectedClassId, controller.classes, onChanged: controller.onClassChanged),
                    _buildDropdownField('Section', controller.selectedSectionId, controller.filteredSections),
                    _buildTextField('Name', controller.nameController, 'Student/Parent name'),
                    _buildTextField('Admission No', controller.admissionNoController, 'Admission no'),
                  ],
                )),
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
          return const Center(child: Text('No users found. Use criteria and click search.'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
              columns: const [
                DataColumn(label: Text('Admission')),
                DataColumn(label: Text('Roll')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Class')),
                DataColumn(label: Text('Student Perm')),
                DataColumn(label: Text('Parent')),
                DataColumn(label: Text('Parent Perm')),
                DataColumn(label: Text('Due Amount')),
              ],
              rows: controller.users.map((row) {
                final classNameStr = row.className != null ? '${row.className}${row.sectionName != null ? ' (${row.sectionName})' : ''}' : '-';
                return DataRow(cells: [
                  DataCell(Text(row.admissionNo ?? '-')),
                  DataCell(Text(row.rollNo ?? '-')),
                  DataCell(Text(row.studentName ?? '-')),
                  DataCell(Text(classNameStr)),
                  DataCell(
                    row.studentUserId != null
                        ? Checkbox(
                            value: row.studentAccessStatus ?? false,
                            onChanged: controller.actionUserId.value == row.studentUserId ? null : (v) => controller.toggleAccess(row.studentUserId!, v ?? false),
                          )
                        : const Text('Not linked', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  DataCell(Text(row.parentName ?? '-')),
                  DataCell(
                    row.parentUserId != null
                        ? Checkbox(
                            value: row.parentAccessStatus ?? false,
                            onChanged: controller.actionUserId.value == row.parentUserId ? null : (v) => controller.toggleAccess(row.parentUserId!, v ?? false),
                          )
                        : const Text('Not linked', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  DataCell(Text(row.dueAmount ?? '-')),
                ]);
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
