import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_group_controller.dart';
import '../models/student_group_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentGroupView extends StatefulWidget {
  const StudentGroupView({super.key});
  @override
  State<StudentGroupView> createState() => _StudentGroupViewState();
}

class _StudentGroupViewState extends State<StudentGroupView> {
  StudentGroupController get _c => Get.find<StudentGroupController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Student Groups',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentGroup),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildForm(),
                const SizedBox(height: 20),
                _buildList(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Obx(() => sectionHeader(
            _c.editingId.value != null ? 'Edit Group' : 'Add Group')),
        const SizedBox(height: 16),
        sFieldLabel('Group Name *'),
        const SizedBox(height: 6),
        sTextField(controller: _c.nameCtrl, hint: 'e.g. Group A, Morning Batch'),
        const SizedBox(height: 14),
        sFieldLabel('Description'),
        const SizedBox(height: 6),
        sTextField(
          controller: _c.descriptionCtrl,
          hint: 'Optional description',
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        Obx(() => Row(children: [
              if (_c.editingId.value != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _c.resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _c.isSaving.value ? null : _c.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _c.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _c.editingId.value != null
                              ? 'Update Group'
                              : 'Save Group',
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ),
            ])),
      ]),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value) {
        return const SchoolLoader();
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: sectionHeader('All Groups (${_c.filtered.length})')),
          sRefreshButton(_c.loadGroups),
        ]),
        const SizedBox(height: 12),
        sSearchBar(
            hint: 'Search groups...',
            onChanged: (v) => _c.searchQuery.value = v),
        const SizedBox(height: 12),
        if (_c.filtered.isEmpty)
          sEmptyState('No groups found.\nAdd your first group above.',
              Icons.group_outlined)
        else
          ...List.generate(_c.filtered.length, (i) {
            final grp = _c.filtered[i];
            return _GroupCard(
              group: grp,
              onEdit: () => _c.startEdit(grp),
              onDelete: () => _confirmDelete(grp),
            );
          }),
      ]);
    });
  }

  void _confirmDelete(StudentGroup grp) {
    showDialog(
      context: context,
      builder: (_) => sDeleteDialog(
        context: context,
        message: 'Delete group "${grp.name}"? This cannot be undone.',
        onConfirm: () => _c.delete(grp.id),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final StudentGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GroupCard(
      {required this.group, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: sCardDecoration,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.group_rounded,
              color: Color(0xFF0EA5E9), size: 20),
        ),
        title: Text(
          group.name,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF111827)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description.isNotEmpty)
              Text(group.description,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            if (group.studentsCount != null)
              Text('${group.studentsCount} students',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          sIconBtn(Icons.edit_outlined, const Color(0xFF4F46E5), onEdit),
          sIconBtn(
              Icons.delete_outline_rounded, const Color(0xFFDC2626), onDelete),
        ]),
      ),
    );
  }
}
