import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/exam_attendance_controller.dart';
import '../models/exam_models.dart';
import '_exam_nav_tabs.dart';

class ExamAttendanceCreateView extends StatelessWidget {
  const ExamAttendanceCreateView({super.key});

  ExamAttendanceController get _c => Get.find<ExamAttendanceController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Examination',
      body: Column(
        children: [
          const ExamNavTabs(activeRoute: AppRoutes.examAttendanceCreate),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: _c.search,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    children: [
                      _SearchCard(c: _c),
                      Obx(() {
                        if (_c.errorMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _StatusBanner(msg: _c.errorMsg.value, isError: true),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.successMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _StatusBanner(msg: _c.successMsg.value, isError: false),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        if (_c.students.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _AttendanceListCard(c: _c),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final ExamAttendanceController c;
  const _SearchCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Search'),
        const SizedBox(height: 16),
        Obx(() => Column(children: [
              sFieldLabel('Exam'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedExamId.value,
                hint: 'Select Exam',
                items: c.examTypes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.title)))
                    .toList(),
                onChanged: (v) => c.selectedExamId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Class'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedClassId.value,
                hint: 'Select Class',
                items: c.classes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) {
                  c.selectedClassId.value = v;
                  c.selectedSectionId.value = null;
                },
              ),
              const SizedBox(height: 12),
              sFieldLabel('Section'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedSectionId.value,
                hint: 'Select Section',
                items: c.filteredSections
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => c.selectedSectionId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Subject'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedSubjectId.value,
                hint: 'Select Subject',
                items: c.subjects
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => c.selectedSubjectId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Date'),
              const SizedBox(height: 6),
              _DateField(
                value: c.selectedDate.value,
                onChanged: (v) => c.selectedDate.value = v,
              ),
            ])),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
                onPressed: c.isSearching.value ? null : c.search,
                icon: c.isSearching.value
                    ? sSavingIndicator()
                    : const Icon(Icons.search_rounded, size: 18),
                label: Text(c.isSearching.value ? 'Searching…' : 'Search',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )),
        ),
      ]),
    );
  }
}

class _DateField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _DateField({required this.value, required this.onChanged});

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _ctrl.text = formatted;
      widget.onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return sTextField(
      controller: _ctrl,
      hint: 'YYYY-MM-DD',
      readOnly: true,
      onTap: _pick,
      suffixIcon: const Icon(Icons.calendar_today_rounded,
          size: 18, color: Color(0xFF9CA3AF)),
    );
  }
}

class _AttendanceListCard extends StatelessWidget {
  final ExamAttendanceController c;
  const _AttendanceListCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          sectionHeader('Students'),
          Row(children: [
            _BulkBtn('All P', const Color(0xFF059669), () => c.markAll('P')),
            const SizedBox(width: 6),
            _BulkBtn('All A', const Color(0xFFDC2626), () => c.markAll('A')),
          ]),
        ]),
        const SizedBox(height: 12),
        Obx(() => Column(
              children: c.students.map((s) => _AttendRow(s: s, c: c)).toList(),
            )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
                onPressed: c.isSaving.value ? null : c.save,
                icon: c.isSaving.value
                    ? sSavingIndicator()
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(c.isSaving.value ? 'Saving…' : 'Save Attendance',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )),
        ),
      ]),
    );
  }
}

class _BulkBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BulkBtn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}

class _AttendRow extends StatelessWidget {
  final AttendanceStudent s;
  final ExamAttendanceController c;
  const _AttendRow({required this.s, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final type = c.attendanceState[s.studentRecordId] ?? 'P';
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.fullName,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827))),
              const SizedBox(height: 2),
              Text('Adm: ${s.admissionNo}  •  Roll: ${s.rollNo}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
            ]),
          ),
          _AttendChip(
              label: 'P',
              selected: type == 'P',
              color: const Color(0xFF059669),
              onTap: () => c.setAttendance(s.studentRecordId, 'P')),
          const SizedBox(width: 6),
          _AttendChip(
              label: 'A',
              selected: type == 'A',
              color: const Color(0xFFDC2626),
              onTap: () => c.setAttendance(s.studentRecordId, 'A')),
          const SizedBox(width: 6),
          _AttendChip(
              label: 'L',
              selected: type == 'L',
              color: const Color(0xFFEA580C),
              onTap: () => c.setAttendance(s.studentRecordId, 'L')),
        ]),
      );
    });
  }
}

class _AttendChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _AttendChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: selected ? 1 : 0.3)),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : color)),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String msg;
  final bool isError;
  const _StatusBanner({required this.msg, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF059669);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(fontSize: 13, color: color))),
      ]),
    );
  }
}
