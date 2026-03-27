import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_disabled_controller.dart';
import '../models/student_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentDisabledView extends StatefulWidget {
  const StudentDisabledView({super.key});
  @override
  State<StudentDisabledView> createState() => _StudentDisabledViewState();
}

class _StudentDisabledViewState extends State<StudentDisabledView> {
  StudentDisabledController get _c => Get.find<StudentDisabledController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Disabled Students',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentDisabled),
        _buildFilters(),
        Expanded(child: _buildList()),
      ]),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(children: [
        sSearchBar(
          hint: 'Search by name or admission no...',
          onChanged: (v) => _c.searchQuery.value = v,
        ),
        const SizedBox(height: 10),
        Obx(() => Row(children: [
              Expanded(child: _DropdownSmall<int?>(
                value: _c.filterClassId.value,
                hint: 'All Classes',
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Classes')),
                  ..._c.classes.map((c) => DropdownMenuItem(
                      value: c['id'] as int,
                      child: Text(c['name'] as String? ?? ''))),
                ],
                onChanged: (v) {
                  _c.filterClassId.value = v;
                  _c.filterSectionId.value = null;
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: _DropdownSmall<int?>(
                value: _c.filterSectionId.value,
                hint: 'All Sections',
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Sections')),
                  ..._c.sectionsForClass.map((s) => DropdownMenuItem(
                      value: s['id'] as int,
                      child: Text(s['name'] as String? ?? ''))),
                ],
                onChanged: (v) => _c.filterSectionId.value = v,
              )),
            ])),
      ]),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
      }
      final items = _c.filtered;
      if (items.isEmpty) {
        return sEmptyState(
            'No disabled students found.\n', Icons.person_off_outlined);
      }
      return RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: _c.loadAll,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          itemCount: items.length,
          itemBuilder: (_, i) => _DisabledStudentCard(
            student: items[i],
            className: _c.className(items[i].currentClass),
            sectionName: _c.sectionName(items[i].currentSection),
            categoryName: _c.categoryName(items[i].category),
            guardianName: _c.guardianName(items[i].guardian),
            guardianPhone: _c.guardianPhone(items[i].guardian),
            onEnable: () => _confirmEnable(items[i]),
            onDelete: () => _confirmDelete(items[i]),
          ),
        ),
      );
    });
  }

  void _confirmEnable(StudentRow s) {
    showDialog(
      context: context,
      builder: (_) => sConfirmDialog(
        context: context,
        title: 'Enable Student',
        message:
            'Enable "${s.fullName}"? This will allow them to appear in regular student lists.',
        confirmLabel: 'Enable',
        confirmColor: const Color(0xFF16A34A),
        onConfirm: () => _c.enableStudent(s.id),
      ),
    );
  }

  void _confirmDelete(StudentRow s) {
    showDialog(
      context: context,
      builder: (_) => sDeleteDialog(
        context: context,
        message: 'Permanently delete "${s.fullName}"? This cannot be undone.',
        onConfirm: () => _c.deleteStudent(s.id),
      ),
    );
  }
}

class _DisabledStudentCard extends StatelessWidget {
  final StudentRow student;
  final String className;
  final String sectionName;
  final String categoryName;
  final String guardianName;
  final String guardianPhone;
  final VoidCallback onEnable;
  final VoidCallback onDelete;

  const _DisabledStudentCard({
    required this.student,
    required this.className,
    required this.sectionName,
    required this.categoryName,
    required this.guardianName,
    required this.guardianPhone,
    required this.onEnable,
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
              child: const Icon(Icons.person_off_rounded,
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
                  'Adm: ${student.admissionNo}${student.rollNo != null ? ' · Roll: ${student.rollNo}' : ''}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280)),
                ),
              ],
            )),
            sBadge('Disabled', const Color(0xFFD97706)),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (className != '—')
              sBadge('$className / $sectionName', const Color(0xFF4F46E5)),
            sBadge(student.genderLabel, const Color(0xFF6B7280)),
            if (categoryName != '—')
              sBadge(categoryName, const Color(0xFF0EA5E9)),
            if (student.dateOfBirth != null)
              sBadge('DOB: ${student.dateOfBirth}',
                  const Color(0xFF6B7280)),
          ]),
          const SizedBox(height: 8),
          if (guardianName != '—')
            Row(children: [
              const Icon(Icons.person_outline_rounded,
                  size: 14, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(guardianName,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
              if (guardianPhone.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.phone_outlined,
                    size: 14, color: Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(guardianPhone,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF6B7280))),
              ],
            ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: onEnable,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
                side: const BorderSide(color: Color(0xFF16A34A)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: Text('Enable',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.delete_forever_rounded, size: 16),
              label: Text('Delete',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _DropdownSmall<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownSmall({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF9CA3AF))),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          underline: const SizedBox(),
          style: GoogleFonts.inter(
              fontSize: 13, color: const Color(0xFF111827)),
          iconSize: 18,
        ),
      );
}
