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
      body: Column(
        children: [
          _buildNavTabs(),
          _buildFilterPanel(context),
          Expanded(child: _buildUserList(context)),
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
            _navChip('Login Permission', AppRoutes.loginPermission, isActive: true),
            const SizedBox(width: 8),
            _navChip('Due Fees', AppRoutes.dueFeesLoginPermission),
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
          color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : const Color(0xFF6B7280)),
        ),
      ),
    );
  }

  // ── Filter panel ─────────────────────────────────────────────────────────
  Widget _buildFilterPanel(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Obx(() {
            final isStudent = controller.isStudentRole;
            return Column(
              children: [
                // Role dropdown
                _buildDropdown(
                  label: 'Role',
                  value: controller.selectedRoleId.value,
                  items: controller.roles,
                  onChanged: (val) => controller.selectedRoleId.value = val,
                ),
                if (isStudent) ...[
                  const SizedBox(height: 10),
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
                      Expanded(child: _buildTextField(label: 'Name', ctrl: controller.nameController, hint: 'Student name')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(label: 'Roll No', ctrl: controller.rollNoController, hint: 'Roll no')),
                    ],
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 12),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoadingCriteria.value || controller.isLoading.value ? null : controller.searchUsers,
                  icon: controller.isLoading.value
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded, size: 18),
                  label: Text(controller.isLoading.value ? 'Searching...' : 'Search Users'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        const SizedBox(height: 4),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(10),
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
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          ),
        ),
      ],
    );
  }

  // ── Results list ─────────────────────────────────────────────────────────
  Widget _buildUserList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.users.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
      }
      if (controller.users.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No users found.\nSelect criteria and search.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey)),
            ],
          ),
        );
      }

      final isStudent = controller.isStudentRole;

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: controller.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final row = controller.users[i];
          return isStudent ? _buildStudentCard(context, row) : _buildStaffCard(context, row);
        },
      );
    });
  }

  Widget _buildStudentCard(BuildContext context, dynamic row) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEDE9FE),
                  radius: 20,
                  child: Text(
                    (row.name as String).isNotEmpty ? (row.name as String)[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF111827))),
                      Text(
                        '${row.className ?? ""}${row.sectionName != null ? " (${row.sectionName})" : ""}'
                        '${row.admissionNo != null ? " · ${row.admissionNo}" : ""}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                // Student access toggle
                Obx(() => _buildAccessSwitch(
                      label: 'Student',
                      value: row.accessStatus as bool,
                      isLoading: controller.actionUserId.value == row.userId,
                      onChanged: (v) => controller.toggleAccess(row.userId, v),
                    )),
              ],
            ),
            const Divider(height: 20),
            // Password reset section
            Text('Student Password Reset', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            _buildPasswordRow(row.userId),
            // Parent section
            if (row.parentUserId != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text('Parent: ${row.parentName ?? "Linked"}',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF374151))),
                  ),
                  Obx(() => _buildAccessSwitch(
                        label: 'Parent',
                        value: (row.parentAccessStatus ?? false) as bool,
                        isLoading: controller.actionUserId.value == row.parentUserId,
                        onChanged: (v) => controller.toggleAccess(row.parentUserId!, v),
                      )),
                ],
              ),
              const SizedBox(height: 8),
              Text('Parent Password Reset', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              _buildPasswordRow(row.parentUserId!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, dynamic row) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFDBEAFE),
                  radius: 20,
                  child: Text(
                    (row.name as String).isNotEmpty ? (row.name as String)[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF111827))),
                      Text(
                        '${row.roleName ?? ""}${row.staffNo != null ? " · ${row.staffNo}" : ""}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                      if (row.email != null)
                        Text(row.email!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Obx(() => _buildAccessSwitch(
                      label: 'Login',
                      value: row.accessStatus as bool,
                      isLoading: controller.actionUserId.value == row.userId,
                      onChanged: (v) => controller.toggleAccess(row.userId, v),
                    )),
              ],
            ),
            const Divider(height: 20),
            Text('Password Reset', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            _buildPasswordRow(row.userId),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessSwitch({
    required String label,
    required bool value,
    required bool isLoading,
    required void Function(bool) onChanged,
  }) {
    if (isLoading) return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)));
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4F46E5),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildPasswordRow(int targetUserId) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              onChanged: (val) => controller.passwordMap[targetUserId] = val,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'New password',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: () => controller.resetPassword(targetUserId, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Update', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          height: 38,
          child: OutlinedButton(
            onPressed: () => controller.resetPassword(targetUserId, true),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Default', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
