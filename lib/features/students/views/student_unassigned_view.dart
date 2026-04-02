import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/school_loader.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_unassigned_controller.dart';
import '../models/student_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentUnassignedView extends StatefulWidget {
  const StudentUnassignedView({super.key});
  @override
  State<StudentUnassignedView> createState() => _StudentUnassignedViewState();
}

class _StudentUnassignedViewState extends State<StudentUnassignedView> {
  StudentUnassignedController get _c =>
      Get.find<StudentUnassignedController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Unassigned Students',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentUnassigned),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: sSearchBar(
            hint: 'Search by name or admission no...',
            onChanged: (v) => _c.searchQuery.value = v,
          ),
        ),
        Expanded(child: _buildList()),
      ]),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value) {
        return const SchoolLoader();
      }
      final items = _c.filtered;
      if (items.isEmpty) {
        return sEmptyState(
            'No unassigned students!\nAll students have been assigned to a class.',
            Icons.check_circle_outline_rounded);
      }
      return RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: _c.loadAll,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          itemCount: items.length,
          itemBuilder: (_, i) => _UnassignedCard(
            student: items[i],
            categoryName: _c.categoryName(items[i].category),
            guardianName: _c.guardianName(items[i].guardian),
            onAssign: () =>
                Get.toNamed('${AppRoutes.studentMultiClass}'),
            onDelete: () => _confirmDelete(items[i]),
          ),
        ),
      );
    });
  }

  void _confirmDelete(StudentRow s) {
    showDialog(
      context: context,
      builder: (_) => sConfirmDialog(
        context: context,
        title: 'Move to Deleted',
        message:
            'Move "${s.fullName}" to deleted records? You can restore them later.',
        confirmLabel: 'Move',
        confirmColor: const Color(0xFFD97706),
        onConfirm: () => _c.softDeleteStudent(s.id),
      ),
    );
  }
}

class _UnassignedCard extends StatelessWidget {
  final StudentRow student;
  final String categoryName;
  final String guardianName;
  final VoidCallback onAssign;
  final VoidCallback onDelete;

  const _UnassignedCard({
    required this.student,
    required this.categoryName,
    required this.guardianName,
    required this.onAssign,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: sCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_search_rounded,
                  color: Color(0xFFD97706), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF111827)),
                ),
                Text(
                  'Adm: ${student.admissionNo}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280)),
                ),
              ],
            )),
            sBadge('No Class', const Color(0xFFD97706)),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            sBadge(student.genderLabel, const Color(0xFF6B7280)),
            if (categoryName != '—')
              sBadge(categoryName, const Color(0xFF0EA5E9)),
            if (guardianName != '—')
              sBadge('Guardian: $guardianName', const Color(0xFF6B7280)),
            if (student.dateOfBirth != null)
              sBadge('DOB: ${student.dateOfBirth}', const Color(0xFF6B7280)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: onAssign,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.class_rounded, size: 16),
              label: Text('Assign Class',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: Text('Remove',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ]),
        ]),
      ),
    );
  }
}
