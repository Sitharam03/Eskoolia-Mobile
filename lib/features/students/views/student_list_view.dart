import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_list_controller.dart';
import '../models/student_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({super.key});
  @override
  State<StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  StudentListController get _c => Get.find<StudentListController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Students',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentList),
        _buildFilters(),
        Expanded(child: _buildList()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.studentAdd),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(children: [
        sSearchBar(
          hint: 'Search by name, admission no, roll no...',
          onChanged: (v) => _c.searchQuery.value = v,
        ),
        const SizedBox(height: 10),
        Obx(() => Row(children: [
              Expanded(
                child: _DropdownFilter<int?>(
                  value: _c.filterClassId.value,
                  hint: 'All Classes',
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Classes')),
                    ..._c.classes.map((c) => DropdownMenuItem(
                          value: c['id'] as int,
                          child: Text(c['name'] as String? ?? ''),
                        )),
                  ],
                  onChanged: (v) {
                    _c.filterClassId.value = v;
                    _c.filterSectionId.value = null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownFilter<int?>(
                  value: _c.filterSectionId.value,
                  hint: 'All Sections',
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Sections')),
                    ..._c.sectionsForClass.map((s) => DropdownMenuItem(
                          value: s['id'] as int,
                          child: Text(s['name'] as String? ?? ''),
                        )),
                  ],
                  onChanged: (v) => _c.filterSectionId.value = v,
                ),
              ),
              const SizedBox(width: 10),
              Obx(() => GestureDetector(
                    onTap: () => _c.filterActiveOnly.value =
                        !_c.filterActiveOnly.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _c.filterActiveOnly.value
                            ? const Color(0xFF4F46E5).withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _c.filterActiveOnly.value
                              ? const Color(0xFF4F46E5)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _c.filterActiveOnly.value
                              ? const Color(0xFF4F46E5)
                              : Colors.grey,
                        ),
                      ),
                    ),
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
            'No students found.\nTry adjusting your filters.',
            Icons.people_outline_rounded);
      }
      return RefreshIndicator(
        color: const Color(0xFF4F46E5),
        onRefresh: _c.loadAll,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: items.length,
          itemBuilder: (_, i) => _StudentCard(
            student: items[i],
            className: _c.className(items[i].currentClass),
            sectionName: _c.sectionName(items[i].currentSection),
            guardianName: _c.guardianName(items[i].guardian),
            onTap: () {},
            onEdit: () {
              // Navigate to add view with editing state
              Get.toNamed(AppRoutes.studentAdd,
                  arguments: {'student': items[i]});
            },
          ),
        ),
      );
    });
  }
}

class _StudentCard extends StatelessWidget {
  final StudentRow student;
  final String className;
  final String sectionName;
  final String guardianName;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _StudentCard({
    required this.student,
    required this.className,
    required this.sectionName,
    required this.guardianName,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final initials = student.firstName.isNotEmpty
        ? student.firstName[0].toUpperCase() +
            (student.lastName?.isNotEmpty == true
                ? student.lastName![0].toUpperCase()
                : '')
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: sCardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF111827)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Adm: ${student.admissionNo}${student.rollNo != null ? ' · Roll: ${student.rollNo}' : ''}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      if (className != '—')
                        _Chip(
                            label: '$className / $sectionName',
                            color: const Color(0xFF0EA5E9)),
                      _Chip(
                          label: student.genderLabel,
                          color: student.gender == 'male'
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFDB2777)),
                      _StatusChip(isActive: student.isActive),
                    ]),
                  ]),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Color(0xFF4F46E5), size: 20),
              onPressed: onEdit,
            ),
          ]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF16A34A).withValues(alpha: 0.1)
              : const Color(0xFFDC2626).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _DropdownFilter<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownFilter({
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
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF))),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          underline: const SizedBox(),
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF111827)),
          iconSize: 18,
        ),
      );
}
