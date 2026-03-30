import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/assign_class_teacher_controller.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';

class AssignClassTeacherView extends GetView<AssignClassTeacherController> {
  const AssignClassTeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Assign Class Teacher',
      body: Column(
        children: [
          const AcademicsNavTabs(
              activeRoute: AppRoutes.academicsAssignClassTeacher),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                );
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: controller.loadItems,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _FilterCard(c: controller),
                    const SizedBox(height: 12),
                    _FormCard(c: controller),
                    const SizedBox(height: 12),
                    _Messages(c: controller),
                    _ItemList(c: controller, context: context),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Filter card ───────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final AssignClassTeacherController c;
  const _FilterCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: aCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          aSectionHeader('Filter'),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: _fieldWidth(context),
                  child: aDropdown<String>(
                    value: c.filterClassId.value.isEmpty
                        ? null
                        : c.filterClassId.value,
                    label: 'Class',
                    items: [
                      DropdownMenuItem(
                          value: '',
                          child: Text('All Classes',
                              style: GoogleFonts.inter(fontSize: 14))),
                      ...c.classes.map(
                        (cl) => DropdownMenuItem(
                          value: cl.id.toString(),
                          child: Text(cl.name,
                              style: GoogleFonts.inter(fontSize: 14)),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      c.filterClassId.value = v ?? '';
                      c.filterSectionId.value = '';
                    },
                  ),
                ),
                SizedBox(
                  width: _fieldWidth(context),
                  child: aDropdown<String>(
                    value: c.filterSectionId.value.isEmpty
                        ? null
                        : c.filterSectionId.value,
                    label: 'Section',
                    items: [
                      DropdownMenuItem(
                          value: '',
                          child: Text('All Sections',
                              style: GoogleFonts.inter(fontSize: 14))),
                      ...c.filterSections.map(
                        (s) => DropdownMenuItem(
                          value: s.id.toString(),
                          child: Text(s.name,
                              style: GoogleFonts.inter(fontSize: 14)),
                        ),
                      ),
                    ],
                    onChanged: (v) =>
                        c.filterSectionId.value = v ?? '',
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: c.loadItems,
                      icon: const Icon(Icons.search_rounded, size: 16),
                      label: Text('Search',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        c.filterClassId.value = '';
                        c.filterSectionId.value = '';
                        c.loadItems();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Reset',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _fieldWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width - 64;
    return w >= 600 ? (w - 12) / 2 : w;
  }
}

// ── Form card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final AssignClassTeacherController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = c.editingId.value != null;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: aCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            aSectionHeader(isEditing ? 'Edit Assignment' : 'Assign Class Teacher'),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 500;
              final fields = <Widget>[
                aDropdown<String>(
                  value: c.yearId.value.isEmpty ? null : c.yearId.value,
                  label: 'Academic Year',
                  items: c.years
                      .map((y) => DropdownMenuItem(
                            value: y.id.toString(),
                            child: Text(y.name,
                                style: GoogleFonts.inter(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => c.yearId.value = v ?? '',
                ),
                aDropdown<String>(
                  value: c.classId.value.isEmpty ? null : c.classId.value,
                  label: 'Class *',
                  items: c.classes
                      .map((cl) => DropdownMenuItem(
                            value: cl.id.toString(),
                            child: Text(cl.name,
                                style: GoogleFonts.inter(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    c.classId.value = v ?? '';
                    c.sectionId.value = '';
                  },
                ),
                aDropdown<String>(
                  value: c.sectionId.value.isEmpty ? null : c.sectionId.value,
                  label: 'Section',
                  items: [
                    DropdownMenuItem(
                        value: '',
                        child: Text('None',
                            style: GoogleFonts.inter(fontSize: 14))),
                    ...c.availableSections.map((s) => DropdownMenuItem(
                          value: s.id.toString(),
                          child: Text(s.name,
                              style: GoogleFonts.inter(fontSize: 14)),
                        )),
                  ],
                  onChanged: (v) => c.sectionId.value = v ?? '',
                ),
                aDropdown<String>(
                  value: c.teacherId.value.isEmpty ? null : c.teacherId.value,
                  label: 'Teacher *',
                  items: c.teachers
                      .map((t) => DropdownMenuItem(
                            value: t.id.toString(),
                            child: Text(t.displayName,
                                style: GoogleFonts.inter(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => c.teacherId.value = v ?? '',
                ),
              ];

              if (wide) {
                return Column(
                  children: [
                    for (int i = 0; i < fields.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(child: fields[i]),
                            if (i + 1 < fields.length) ...[
                              const SizedBox(width: 12),
                              Expanded(child: fields[i + 1]),
                            ],
                          ],
                        ),
                      ),
                  ],
                );
              }

              return Column(
                children: fields
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: f,
                        ))
                    .toList(),
              );
            }),
            const SizedBox(height: 4),
            if (isEditing)
              Row(
                children: [
                  Expanded(
                    child: aSecondaryBtn('Cancel', () => c.resetForm()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: aPrimaryBtn(
                      'Update',
                      c.save,
                      isLoading: c.isSaving.value,
                    ),
                  ),
                ],
              )
            else
              aPrimaryBtn(
                'Assign',
                c.save,
                isLoading: c.isSaving.value,
              ),
          ],
        ),
      );
    });
  }
}

// ── Messages ──────────────────────────────────────────────────────────────────

class _Messages extends StatelessWidget {
  final AssignClassTeacherController c;
  const _Messages({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.error.value.isNotEmpty) {
        return _msgBanner(c.error.value, const Color(0xFFFEE2E2),
            const Color(0xFFDC2626), Icons.error_outline_rounded);
      }
      if (c.message.value.isNotEmpty) {
        return _msgBanner(c.message.value, const Color(0xFFD1FAE5),
            const Color(0xFF059669), Icons.check_circle_outline_rounded);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _msgBanner(
      String text, Color bg, Color fg, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: fg, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ── Item list ─────────────────────────────────────────────────────────────────

class _ItemList extends StatelessWidget {
  final AssignClassTeacherController c;
  final BuildContext context;
  const _ItemList({required this.c, required this.context});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: aSavingIndicator(),
        );
      }
      if (c.items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: aEmptyState(
              'No class teacher assignments yet.\nUse the form above to assign.'),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: aSectionHeader('Assignments (${c.items.length})'),
          ),
          ...c.items.map((item) {
            return aInfoCard(
              title: '${c.className(item.classId)} — ${c.sectionName(item.sectionId)}',
              subtitle: 'Teacher: ${c.teacherName(item.teacherId)}',
              trailing: item.academicYearId != null
                  ? aBadge(
                      c.years
                              .firstWhereOrNull(
                                  (y) => y.id == item.academicYearId)
                              ?.name ??
                          '',
                      const Color(0xFF4F46E5))
                  : null,
              onEdit: () => c.startEdit(item),
              onDelete: () async {
                final ok = await aDeleteDialog(
                  context,
                  'Delete assignment for ${c.className(item.classId)}?',
                );
                if (ok) c.delete(item.id);
              },
            );
          }),
        ],
      );
    });
  }
}
