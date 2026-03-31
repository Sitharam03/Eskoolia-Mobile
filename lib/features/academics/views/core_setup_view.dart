import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/core_setup_controller.dart';
import '../models/academics_models.dart';
import '_academics_nav_tabs.dart';

class CoreSetupView extends GetView<CoreSetupController> {
  const CoreSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Core Setup',
      body: Column(
        children: [
          const AcademicsNavTabs(activeRoute: AppRoutes.academicsCoreSetup),
          // Inner tab row — scrollable so "Academic Years" fits on narrow phones
          Obx(() => Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _tabBtn(0, 'Academic Years'),
                      _tabBtn(1, 'Classes'),
                      _tabBtn(2, 'Sections'),
                      _tabBtn(3, 'Subjects'),
                    ],
                  ),
                ),
              )),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: Obx(() {
              switch (controller.activeTab.value) {
                case 0:
                  return _YearsTab(c: controller);
                case 1:
                  return _ClassesTab(c: controller);
                case 2:
                  return _SectionsTab(c: controller);
                default:
                  return _SubjectsTab(c: controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(int index, String label) {
    final active = controller.activeTab.value == index;
    return GestureDetector(
      onTap: () => controller.activeTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? const Color(0xFF4F46E5) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

Widget _formCard({required Widget child}) => Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );

Widget _field(String label, {required Widget child}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280))),
        const SizedBox(height: 4),
        child,
      ],
    );

InputDecoration _inputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isDense: true,
    );

Widget _saveBtn(String label, bool saving, VoidCallback onTap) => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: saving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );

Widget _cancelBtn(VoidCallback onTap) => SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        child: Text('Cancel',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF6B7280))),
      ),
    );

Widget _errorBanner(String msg) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style:
                    GoogleFonts.inter(fontSize: 12, color: const Color(0xFFDC2626)))),
      ]),
    );

Widget _sectionHeader(String title, int count) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF374151))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text('$count',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4F46E5))),
        ),
      ]),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Academic Years Tab
// ─────────────────────────────────────────────────────────────────────────────

class _YearsTab extends StatelessWidget {
  final CoreSetupController c;
  const _YearsTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Form ──
          _formCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                    key: ValueKey('year_form_${c.editingYearId.value}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form header
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.calendar_today,
                              size: 16, color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          c.editingYearId.value != null
                              ? 'Edit Academic Year'
                              : 'Add Academic Year',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      _field(
                        'YEAR NAME',
                        child: TextFormField(
                          initialValue: c.yearName.value,
                          onChanged: (v) => c.yearName.value = v,
                          decoration: _inputDec('e.g. 2025-2026'),
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _field(
                            'START DATE',
                            child: _DatePickerField(
                              value: c.yearStartDate.value,
                              onChanged: (v) => c.yearStartDate.value = v,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'END DATE',
                            child: _DatePickerField(
                              value: c.yearEndDate.value,
                              onChanged: (v) => c.yearEndDate.value = v,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () =>
                            c.yearIsCurrent.value = !c.yearIsCurrent.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: c.yearIsCurrent.value
                                ? const Color(0xFF4F46E5).withOpacity(0.06)
                                : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: c.yearIsCurrent.value
                                  ? const Color(0xFF4F46E5).withOpacity(0.3)
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                          child: Row(children: [
                            Icon(
                              c.yearIsCurrent.value
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: c.yearIsCurrent.value
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 8),
                            Text('Mark as Current Year',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: c.yearIsCurrent.value
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFF374151))),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (c.yearsError.isNotEmpty)
                        _errorBanner(c.yearsError.value),
                      _saveBtn(
                        c.editingYearId.value != null
                            ? 'Update Year'
                            : 'Save Year',
                        c.yearsSaving.value,
                        c.saveYear,
                      ),
                      if (c.editingYearId.value != null) ...[
                        const SizedBox(height: 8),
                        _cancelBtn(c.resetYearForm),
                      ],
                    ],
                  )),
            ),
          ),
          // ── List ──
          Obx(() {
            if (c.yearsLoading.value) {
              return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()));
            }
            if (c.years.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                    child: Column(children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('No academic years yet.',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF9CA3AF), fontSize: 13)),
                ])),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionHeader('Academic Years', c.years.length),
                ...c.years.map((y) => _YearCard(
                      year: y,
                      onEdit: () => c.startEditYear(y),
                      onDelete: () => _confirmDelete(
                          context, 'Delete "${y.name}"?',
                          () => c.deleteYear(y.id)),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Modern year card
class _YearCard extends StatelessWidget {
  final AcademicYear year;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _YearCard(
      {required this.year, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          // Header gradient strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: year.isCurrent
                    ? [const Color(0xFF4F46E5), const Color(0xFF6366F1)]
                    : [const Color(0xFF6B7280), const Color(0xFF9CA3AF)],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_month,
                  size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(year.name,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              if (year.isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle,
                        size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('Current',
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ]),
                ),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              // Date range
              Expanded(
                child: Row(children: [
                  _datePill(Icons.play_arrow_rounded,
                      const Color(0xFF10B981), year.startDate),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward,
                        size: 12, color: Color(0xFF9CA3AF)),
                  ),
                  _datePill(Icons.stop_rounded,
                      const Color(0xFFEF4444), year.endDate),
                ]),
              ),
              // Actions
              Row(children: [
                _iconAction(Icons.edit_outlined, const Color(0xFF0EA5E9), onEdit),
                const SizedBox(width: 6),
                _iconAction(
                    Icons.delete_outline, const Color(0xFFEF4444), onDelete),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _datePill(IconData icon, Color color, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(date.isEmpty ? '--' : date,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color)),
      ]),
    );
  }

  Widget _iconAction(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Classes Tab
// ─────────────────────────────────────────────────────────────────────────────

class _ClassesTab extends StatelessWidget {
  final CoreSetupController c;
  const _ClassesTab({required this.c});

  // Accent colours cycling per class card
  static const _accentColors = [
    Color(0xFF4F46E5),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFF7C3AED),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Form card ──
          _formCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                    key: ValueKey('class_form_${c.editingClassId.value}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.class_outlined,
                              size: 16, color: Color(0xFF0EA5E9)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          c.editingClassId.value != null
                              ? 'Edit Class'
                              : 'Add Class',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(
                          flex: 3,
                          child: _field(
                            'CLASS NAME',
                            child: TextFormField(
                              initialValue: c.className.value,
                              onChanged: (v) => c.className.value = v,
                              decoration: _inputDec('e.g. Grade 1'),
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'SORT ORDER',
                            child: TextFormField(
                              initialValue: c.classOrder.value,
                              onChanged: (v) => c.classOrder.value = v,
                              decoration: _inputDec('0'),
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      if (c.classesError.isNotEmpty)
                        _errorBanner(c.classesError.value),
                      _saveBtn(
                        c.editingClassId.value != null
                            ? 'Update Class'
                            : 'Save Class',
                        c.classesSaving.value,
                        c.saveClass,
                      ),
                      if (c.editingClassId.value != null) ...[
                        const SizedBox(height: 8),
                        _cancelBtn(c.resetClassForm),
                      ],
                    ],
                  )),
            ),
          ),
          // ── List ──
          Obx(() {
            if (c.classesLoading.value) {
              return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()));
            }
            if (c.classes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                    child: Column(children: [
                  Icon(Icons.class_outlined,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('No classes yet.',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF9CA3AF), fontSize: 13)),
                ])),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionHeader('Classes', c.classes.length),
                ...c.classes.asMap().entries.map((e) {
                  final cl = e.value;
                  final accent =
                      _accentColors[e.key % _accentColors.length];
                  return _ClassCard(
                    schoolClass: cl,
                    accent: accent,
                    onEdit: () => c.startEditClass(cl),
                    onDelete: () => _confirmDelete(context,
                        'Delete "${cl.name}"?', () => c.deleteClass(cl.id)),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Modern class card — shows name, order, section count, and nested sections
class _ClassCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final Color accent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ClassCard(
      {required this.schoolClass,
      required this.accent,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final sections = schoolClass.sections;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                  bottom: BorderSide(color: accent.withOpacity(0.12))),
            ),
            child: Row(children: [
              // Class icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    schoolClass.name.isNotEmpty
                        ? schoolClass.name[0].toUpperCase()
                        : 'C',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: accent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + order
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schoolClass.name,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827))),
                    const SizedBox(height: 3),
                    Row(children: [
                      _infoPill(Icons.sort,
                          'Order #${schoolClass.numericOrder}', accent),
                      const SizedBox(width: 6),
                      _infoPill(
                          Icons.meeting_room_outlined,
                          '${sections.length} Section${sections.length != 1 ? 's' : ''}',
                          const Color(0xFF7C3AED)),
                    ]),
                  ],
                ),
              ),
              // Actions
              Column(children: [
                _iconBtn(Icons.edit_outlined, const Color(0xFF0EA5E9),
                    onEdit),
                const SizedBox(height: 6),
                _iconBtn(Icons.delete_outline, const Color(0xFFEF4444),
                    onDelete),
              ]),
            ]),
          ),
          // ── Sections row ──
          if (sections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SECTIONS',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFF9CA3AF))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: sections.map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: accent.withOpacity(0.2), width: 1),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.people_outline,
                              size: 11, color: accent),
                          const SizedBox(width: 4),
                          Text(s.name,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent)),
                          const SizedBox(width: 4),
                          Text('(${s.capacity})',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: accent.withOpacity(0.7))),
                        ]),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Text('No sections added yet.',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF9CA3AF))),
            ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(7)),
          child: Icon(icon, size: 15, color: color),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sections Tab
// ─────────────────────────────────────────────────────────────────────────────

class _SectionsTab extends StatelessWidget {
  final CoreSetupController c;
  const _SectionsTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _formCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                    key: ValueKey('section_form_${c.editingSectionId.value}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.meeting_room_outlined,
                              size: 16, color: Color(0xFF7C3AED)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          c.editingSectionId.value != null
                              ? 'Edit Section'
                              : 'Add Section',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      _field(
                        'CLASS',
                        child: DropdownButtonFormField<String>(
                          value: c.sectionClassId.value.isEmpty
                              ? null
                              : c.sectionClassId.value,
                          onChanged: (v) => c.sectionClassId.value = v ?? '',
                          decoration: _inputDec('Select class'),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF111827)),
                          items: c.classes
                              .map((cl) => DropdownMenuItem(
                                  value: cl.id.toString(),
                                  child: Text(cl.name)))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: _field(
                            'SECTION NAME',
                            child: TextFormField(
                              initialValue: c.sectionName.value,
                              onChanged: (v) => c.sectionName.value = v,
                              decoration: _inputDec('e.g. A'),
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'CAPACITY',
                            child: TextFormField(
                              initialValue: c.sectionCapacity.value,
                              onChanged: (v) => c.sectionCapacity.value = v,
                              decoration: _inputDec('0'),
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      if (c.sectionsError.isNotEmpty)
                        _errorBanner(c.sectionsError.value),
                      _saveBtn(
                        c.editingSectionId.value != null
                            ? 'Update Section'
                            : 'Save Section',
                        c.sectionsSaving.value,
                        c.saveSection,
                      ),
                      if (c.editingSectionId.value != null) ...[
                        const SizedBox(height: 8),
                        _cancelBtn(c.resetSectionForm),
                      ],
                    ],
                  )),
            ),
          ),
          Obx(() {
            if (c.sectionsLoading.value) {
              return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()));
            }
            if (c.sections.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                    child: Text('No sections yet.',
                        style: GoogleFonts.inter(
                            color: const Color(0xFF9CA3AF), fontSize: 13))),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionHeader('Sections', c.sections.length),
                ...c.sections.map((s) => _SectionCard(
                      section: s,
                      className: c.className_(s.schoolClass),
                      onEdit: () => c.startEditSection(s),
                      onDelete: () => _confirmDelete(
                          context,
                          'Delete "${s.name}"?',
                          () => c.deleteSection(s.id)),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Section section;
  final String className;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SectionCard({
    required this.section,
    required this.className,
    required this.onEdit,
    required this.onDelete,
  });

  static const _accent = Color(0xFF7C3AED);

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: color),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(13)),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.meeting_room_outlined,
                          size: 20, color: _accent),
                    ),
                    const SizedBox(width: 12),
                    // Section name + class tag + capacity
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(section.name,
                              style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827))),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Class tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.school_outlined,
                                          size: 10,
                                          color: Color(0xFF4F46E5)),
                                      const SizedBox(width: 4),
                                      Text(className,
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4F46E5))),
                                    ]),
                              ),
                              // Capacity tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people_outline,
                                          size: 10, color: _accent),
                                      const SizedBox(width: 4),
                                      Text('Cap: ${section.capacity}',
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: _accent)),
                                    ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _actionBtn(Icons.edit_outlined,
                            const Color(0xFF0EA5E9), onEdit),
                        const SizedBox(height: 6),
                        _actionBtn(Icons.delete_outline,
                            const Color(0xFFEF4444), onDelete),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subjects Tab
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectsTab extends StatelessWidget {
  final CoreSetupController c;
  const _SubjectsTab({required this.c});

  static const _types = ['compulsory', 'elective', 'optional'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _formCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                    key: ValueKey('subject_form_${c.editingSubjectId.value}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.book_outlined,
                              size: 16, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          c.editingSubjectId.value != null
                              ? 'Edit Subject'
                              : 'Add Subject',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      _field(
                        'SUBJECT NAME',
                        child: TextFormField(
                          initialValue: c.subjectName.value,
                          onChanged: (v) => c.subjectName.value = v,
                          decoration: _inputDec('e.g. Mathematics'),
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _field(
                            'CODE',
                            child: TextFormField(
                              initialValue: c.subjectCode.value,
                              onChanged: (v) => c.subjectCode.value = v,
                              decoration: _inputDec('MATH'),
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            'TYPE',
                            child: DropdownButtonFormField<String>(
                              value: c.subjectType.value,
                              onChanged: (v) =>
                                  c.subjectType.value = v ?? 'compulsory',
                              decoration: _inputDec(''),
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF111827)),
                              items: _types
                                  .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                          t[0].toUpperCase() + t.substring(1))))
                                  .toList(),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      if (c.subjectsError.isNotEmpty)
                        _errorBanner(c.subjectsError.value),
                      _saveBtn(
                        c.editingSubjectId.value != null
                            ? 'Update Subject'
                            : 'Save Subject',
                        c.subjectsSaving.value,
                        c.saveSubject,
                      ),
                      if (c.editingSubjectId.value != null) ...[
                        const SizedBox(height: 8),
                        _cancelBtn(c.resetSubjectForm),
                      ],
                    ],
                  )),
            ),
          ),
          Obx(() {
            if (c.subjectsLoading.value) {
              return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()));
            }
            if (c.subjects.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                    child: Column(children: [
                  Icon(Icons.book_outlined,
                      size: 40, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('No subjects yet.',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF9CA3AF), fontSize: 13)),
                ])),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionHeader('Subjects', c.subjects.length),
                ...c.subjects.map((s) => _SubjectCard(
                      subject: s,
                      onEdit: () => c.startEditSubject(s),
                      onDelete: () => _confirmDelete(
                          context,
                          'Delete "${s.name}"?',
                          () => c.deleteSubject(s.id)),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Modern subject card
class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SubjectCard(
      {required this.subject, required this.onEdit, required this.onDelete});

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(7)),
          child: Icon(icon, size: 15, color: color),
        ),
      );

  static Color _typeColor(String type) {
    switch (type) {
      case 'elective':
        return const Color(0xFF0EA5E9);
      case 'optional':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'elective':
        return Icons.tune;
      case 'optional':
        return Icons.add_circle_outline;
      default:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(subject.subjectType);
    final typeLabel =
        subject.subjectType[0].toUpperCase() + subject.subjectType.substring(1);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(13)),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  // Icon circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_typeIcon(subject.subjectType),
                        size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  // Name + code + badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(subject.name,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827))),
                        const SizedBox(height: 4),
                        Row(children: [
                          if (subject.code.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(subject.code,
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF6B7280))),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_typeIcon(subject.subjectType),
                                      size: 9, color: color),
                                  const SizedBox(width: 3),
                                  Text(typeLabel,
                                      style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: color)),
                                ]),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  // Actions
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionBtn(Icons.edit_outlined,
                          const Color(0xFF0EA5E9), onEdit),
                      const SizedBox(height: 6),
                      _actionBtn(Icons.delete_outline,
                          const Color(0xFFEF4444), onDelete),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date picker field
// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _DatePickerField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final initial = DateTime.tryParse(value) ?? DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(
              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              value.isEmpty ? 'Select date' : value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: value.isEmpty
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827)),
            ),
          ),
          const Icon(Icons.calendar_today_outlined,
              size: 15, color: Color(0xFF6B7280)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirm delete dialog
// ─────────────────────────────────────────────────────────────────────────────

void _confirmDelete(
    BuildContext context, String message, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.delete_outline,
              size: 18, color: Color(0xFFDC2626)),
        ),
        const SizedBox(width: 10),
        Text('Confirm Delete',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      content: Text(message,
          style:
              GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Text('Delete',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
