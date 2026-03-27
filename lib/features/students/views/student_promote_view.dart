import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_promote_controller.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentPromoteView extends StatefulWidget {
  const StudentPromoteView({super.key});
  @override
  State<StudentPromoteView> createState() => _StudentPromoteViewState();
}

class _StudentPromoteViewState extends State<StudentPromoteView> {
  StudentPromoteController get _c => Get.find<StudentPromoteController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Promote Students',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentPromote),
        Obx(() {
          if (_c.isLoading.value && _c.classes.isEmpty) {
            return const Expanded(
                child: Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF4F46E5))));
          }
          return Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildSourceFilter(),
                const SizedBox(height: 16),
                _buildStudentList(),
                const SizedBox(height: 16),
                _buildTargetSection(),
                const SizedBox(height: 24),
                _buildPromoteButton(),
                const SizedBox(height: 40),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildSourceFilter() {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.filter_list_rounded,
              color: Color(0xFF4F46E5), size: 18),
          const SizedBox(width: 8),
          Text('Source Class',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: const Color(0xFF111827))),
        ]),
        const SizedBox(height: 14),
        Obx(() => Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Class *'),
                  const SizedBox(height: 6),
                  sDropdown<int>(
                    value: _c.sourceClassId.value,
                    hint: 'Select class',
                    items: _c.classes
                        .map((c) => DropdownMenuItem(
                            value: c['id'] as int,
                            child: Text(c['name'] as String? ?? '')))
                        .toList(),
                    onChanged: (v) {
                      _c.sourceClassId.value = v;
                      _c.sourceSectionId.value = null;
                      _c.students.clear();
                      _c.selectedStudentIds.clear();
                    },
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sFieldLabel('Section'),
                  const SizedBox(height: 6),
                  sDropdown<int>(
                    value: _c.sourceSectionId.value,
                    hint: 'All sections',
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All sections')),
                      ..._c.sourceSections.map((s) => DropdownMenuItem(
                          value: s['id'] as int,
                          child: Text(s['name'] as String? ?? ''))),
                    ],
                    onChanged: (v) => _c.sourceSectionId.value = v,
                  ),
                ],
              )),
            ])),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                _c.isLoading.value ? null : _c.searchStudents,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0EA5E9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: _c.isLoading.value
                ? sSavingIndicator()
                : const Icon(Icons.search_rounded, size: 18),
            label: Text('Search Students',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Widget _buildStudentList() {
    return Obx(() {
      if (_c.students.isEmpty) return const SizedBox.shrink();
      return Container(
        decoration: sCardDecoration,
        child: Column(children: [
          // Header with select all
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                    '${_c.students.length} Students Found',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF111827))),
              ),
              TextButton(
                onPressed: _c.selectedStudentIds.length ==
                        _c.students.length
                    ? _c.clearAll
                    : _c.selectAll,
                child: Text(
                    _c.selectedStudentIds.length == _c.students.length
                        ? 'Deselect All'
                        : 'Select All',
                    style: GoogleFonts.inter(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ]),
          ),
          // Student checkboxes
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _c.students.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = _c.students[i];
              final isSelected =
                  _c.selectedStudentIds.contains(s.id);
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14),
                leading: Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF4F46E5),
                  onChanged: (_) =>
                      _c.toggleStudentSelection(s.id),
                ),
                title: Text(s.fullName,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                    'Adm: ${s.admissionNo}${s.rollNo != null ? ' · Roll: ${s.rollNo}' : ''}',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280))),
                onTap: () => _c.toggleStudentSelection(s.id),
                trailing: sBadge(
                    '${_c.className(s.currentClass)} / ${_c.sectionName(s.currentSection)}',
                    const Color(0xFF0EA5E9)),
              );
            },
          ),
          if (_c.selectedStudentIds.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4F46E5), size: 16),
                const SizedBox(width: 6),
                Text(
                    '${_c.selectedStudentIds.length} student(s) selected',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600)),
              ]),
            ),
        ]),
      );
    });
  }

  Widget _buildTargetSection() {
    return Obx(() {
      if (_c.students.isEmpty) return const SizedBox.shrink();
      return Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.arrow_forward_rounded,
                color: Color(0xFF16A34A), size: 18),
            const SizedBox(width: 8),
            Text('Promote To',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF111827))),
          ]),
          const SizedBox(height: 14),
          sFieldLabel('Academic Year *'),
          const SizedBox(height: 6),
          sDropdown<int>(
            value: _c.targetAcademicYearId.value,
            hint: 'Select academic year',
            items: _c.academicYears
                .map((y) => DropdownMenuItem(
                    value: y['id'] as int,
                    child: Text(y['name'] as String? ??
                        y['title'] as String? ??
                        '${y['id']}')))
                .toList(),
            onChanged: (v) => _c.targetAcademicYearId.value = v,
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sFieldLabel('Target Class *'),
                const SizedBox(height: 6),
                sDropdown<int>(
                  value: _c.targetClassId.value,
                  hint: 'Select class',
                  items: _c.classes
                      .map((c) => DropdownMenuItem(
                          value: c['id'] as int,
                          child: Text(c['name'] as String? ?? '')))
                      .toList(),
                  onChanged: (v) {
                    _c.targetClassId.value = v;
                    _c.targetSectionId.value = null;
                  },
                ),
              ],
            )),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sFieldLabel('Target Section'),
                const SizedBox(height: 6),
                sDropdown<int>(
                  value: _c.targetSectionId.value,
                  hint: 'Optional',
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('No section')),
                    ..._c.targetSections.map((s) => DropdownMenuItem(
                        value: s['id'] as int,
                        child: Text(s['name'] as String? ?? ''))),
                  ],
                  onChanged: (v) => _c.targetSectionId.value = v,
                ),
              ],
            )),
          ]),
        ]),
      );
    });
  }

  Widget _buildPromoteButton() {
    return Obx(() {
      if (_c.students.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _c.isPromoting.value ? null : _c.promote,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: _c.isPromoting.value
              ? sSavingIndicator()
              : const Icon(Icons.upgrade_rounded, size: 22),
          label: Text(
              _c.isPromoting.value
                  ? 'Promoting...'
                  : 'Promote ${_c.selectedStudentIds.length} Student(s)',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      );
    });
  }
}
