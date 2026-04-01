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
      body: Column(
        children: [
          _buildNavTabs(),
          _buildFilterPanel(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  // ── Navigation chips ─────────────────────────────────────────────────────
  Widget _buildNavTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _navChip('Roles', AppRoutes.roles),
            const SizedBox(width: 8),
            _navChip('Assign Permission', AppRoutes.assignPermission),
            const SizedBox(width: 8),
            _navChip('Login Permission', AppRoutes.loginPermission),
            const SizedBox(width: 8),
            _navChip('Due Fees', AppRoutes.dueFeesLoginPermission, isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _navChip(String label, String route, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: const Color(0xFFE0E4EF)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  // ── Filter panel ─────────────────────────────────────────────────────────
  Widget _buildFilterPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          label: 'Class',
                          value: controller.selectedClassId.value,
                          items: controller.classes,
                          onChanged: controller.onClassChanged,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdown(
                          label: 'Section',
                          value: controller.selectedSectionId.value,
                          items: controller.filteredSections,
                          onChanged: (val) => controller.selectedSectionId.value = val,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(label: 'Name', ctrl: controller.nameController, hint: 'Student/Parent name')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(label: 'Admission No', ctrl: controller.admissionNoController, hint: 'Admission no')),
                    ],
                  ),
                ],
              )),
          const SizedBox(height: 12),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 46,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoadingCriteria.value || controller.isLoading.value ? null : controller.searchUsers,
                    icon: controller.isLoading.value
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search_rounded, size: 18),
                    label: Text(controller.isLoading.value ? 'Searching...' : 'Search Students'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<dynamic> items, required void Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        const SizedBox(height: 4),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            border: Border.all(color: const Color(0xFFE0E4EF)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Text('Select', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 18),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
              items: items.map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.name))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required TextEditingController ctrl, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF5F7FF),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E4EF))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E4EF))),
          ),
        ),
      ],
    );
  }

  // ── Results list ─────────────────────────────────────────────────────────
  Widget _buildUserList() {
    return Obx(() {
      if (controller.isLoading.value && controller.users.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
      }
      if (controller.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No students found.\nUse criteria and search.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: controller.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _buildStudentCard(controller.users[i]),
      );
    });
  }

  Widget _buildStudentCard(dynamic row) {
    final classNameStr = row.className != null
        ? '${row.className}${row.sectionName != null ? " (${row.sectionName})" : ""}'
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFFCFCFF)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E4EF)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student basic info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFEF3C7),
                  radius: 20,
                  child: Text(
                    (row.studentName as String? ?? '?').isNotEmpty ? (row.studentName as String)[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.studentName ?? 'Unknown',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF111827)),
                      ),
                      Text(
                        [
                          if (classNameStr != null) classNameStr,
                          if (row.admissionNo != null) 'Adm: ${row.admissionNo}',
                          if (row.rollNo != null) 'Roll: ${row.rollNo}',
                        ].join(' · '),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                // Due amount badge
                if (row.dueAmount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('Due', style: TextStyle(fontSize: 10, color: Color(0xFFDC2626))),
                        Text(
                          '₹${row.dueAmount}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const Divider(height: 20),

            // Student access + Parent access row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Student Access', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      if (row.studentUserId != null)
                        Obx(() => Row(
                              children: [
                                Switch(
                                  value: row.studentAccessStatus ?? false,
                                  onChanged: controller.actionUserId.value == row.studentUserId
                                      ? null
                                      : (v) => controller.toggleAccess(row.studentUserId!, v),
                                  activeColor: const Color(0xFF4F46E5),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                if (controller.actionUserId.value == row.studentUserId)
                                  const SizedBox(width: 4, height: 4, child: CircularProgressIndicator(strokeWidth: 2)),
                              ],
                            ))
                      else
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('Not linked', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                        ),
                    ],
                  ),
                ),
                if (row.parentName != null || row.parentUserId != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parent: ${row.parentName ?? "Linked"}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (row.parentUserId != null)
                          Obx(() => Row(
                                children: [
                                  Switch(
                                    value: row.parentAccessStatus ?? false,
                                    onChanged: controller.actionUserId.value == row.parentUserId
                                        ? null
                                        : (v) => controller.toggleAccess(row.parentUserId!, v),
                                    activeColor: const Color(0xFF4F46E5),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  if (controller.actionUserId.value == row.parentUserId)
                                    const SizedBox(width: 4, height: 4, child: CircularProgressIndicator(strokeWidth: 2)),
                                ],
                              ))
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: Text('Not linked', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
