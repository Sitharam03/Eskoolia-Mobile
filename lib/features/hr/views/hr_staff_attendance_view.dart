import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_staff_attendance_controller.dart';
import '_hr_nav_tabs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main View
// ─────────────────────────────────────────────────────────────────────────────

class HrStaffAttendanceView extends StatelessWidget {
  const HrStaffAttendanceView({super.key});

  HrStaffAttendanceController get c =>
      Get.find<HrStaffAttendanceController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Human Resource',
      body: Column(children: [
        const HrNavTabs(activeRoute: AppRoutes.hrStaffAttendance),
        Expanded(
          child: Obx(() {
            if (c.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
              );
            }
            return RefreshIndicator(
              color: const Color(0xFF4F46E5),
              onRefresh: c.load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateSelectorCard(c: c),
                    const SizedBox(height: 14),
                    _SummaryRow(c: c),
                    const SizedBox(height: 14),
                    Obx(() => c.successMsg.value.isNotEmpty
                        ? _SuccessBanner(msg: c.successMsg.value)
                        : const SizedBox.shrink()),
                    Obx(() => c.errorMsg.value.isNotEmpty
                        ? _ErrorBanner(msg: c.errorMsg.value)
                        : const SizedBox.shrink()),
                    const SizedBox(height: 4),
                    _AttendanceTableCard(c: c),
                  ],
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date Selector Card
// ─────────────────────────────────────────────────────────────────────────────

class _DateSelectorCard extends StatelessWidget {
  final HrStaffAttendanceController c;
  const _DateSelectorCard({required this.c});

  Future<void> _pickDate(BuildContext context) async {
    final current = DateTime.tryParse(c.selectedDate.value) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4F46E5),
            onPrimary: Colors.white,
            onSurface: Color(0xFF111827),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      c.selectedDate.value =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      c.load();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Attendance Date',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: AbsorbPointer(
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            c.selectedDate.value.isEmpty
                                ? 'Select date…'
                                : c.selectedDate.value,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: c.selectedDate.value.isEmpty
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF111827),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: Color(0xFF6B7280),
                        ),
                      ]),
                    )),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Row
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final HrStaffAttendanceController c;
  const _SummaryRow({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final chips = [
          _ChipData(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF059669),
            count: c.presentCount,
            label: 'Present',
          ),
          _ChipData(
            icon: Icons.cancel_rounded,
            color: const Color(0xFFDC2626),
            count: c.absentCount,
            label: 'Absent',
          ),
          _ChipData(
            icon: Icons.event_busy_rounded,
            color: const Color(0xFFEA580C),
            count: c.leaveCount,
            label: 'Leave',
          ),
          _ChipData(
            icon: Icons.looks_two_rounded,
            color: const Color(0xFF8B5CF6),
            count: c.halfDayCount,
            label: 'Half Day',
          ),
          _ChipData(
            icon: Icons.celebration_rounded,
            color: const Color(0xFF0EA5E9),
            count: c.holidayCount,
            label: 'Holiday',
          ),
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chips
                .map((d) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: d.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Icon(d.icon, size: 18, color: d.color),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${d.count}',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Text(
                            d.label,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        );
      });
}

class _ChipData {
  final IconData icon;
  final Color color;
  final int count;
  final String label;
  const _ChipData(
      {required this.icon,
      required this.color,
      required this.count,
      required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// Banners
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  final String msg;
  const _SuccessBanner({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.08),
          border: Border.all(
              color: const Color(0xFF059669).withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded,
              size: 18, color: Color(0xFF059669)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF065F46),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ]),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withValues(alpha: 0.08),
          border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          const Icon(Icons.error_rounded,
              size: 18, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF991B1B),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Attendance Table Card
// ─────────────────────────────────────────────────────────────────────────────

class _AttendanceTableCard extends StatelessWidget {
  final HrStaffAttendanceController c;
  const _AttendanceTableCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mark Attendance',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Obx(() => Text(
                        '${c.attendanceRows.length} Staff',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ],
              ),
            ),

            // Staff rows
            Obx(() {
              if (c.attendanceRows.isEmpty) {
                return sEmptyState(
                    'No active staff', Icons.people_outline_rounded);
              }
              return Column(
                children: List.generate(
                  c.attendanceRows.length,
                  (i) => _AttendanceRow(
                    row: c.attendanceRows[i],
                    isEven: i % 2 == 0,
                  ),
                ),
              );
            }),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: c.isSaving.value ? null : c.saveAttendance,
                      icon: c.isSaving.value
                          ? sSavingIndicator()
                          : const Icon(Icons.save_rounded, size: 18),
                      label: Text(
                        c.isSaving.value ? 'Saving…' : 'Save Attendance',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF4F46E5).withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Attendance Row
// ─────────────────────────────────────────────────────────────────────────────

class _AttendanceRow extends StatelessWidget {
  final AttendanceRow row;
  final bool isEven;
  const _AttendanceRow({required this.row, required this.isEven});

  @override
  Widget build(BuildContext context) => Container(
        color: isEven ? Colors.white : const Color(0xFFFAFAFF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main row content
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      row.staff.initials,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & staff no
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.staff.fullName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          row.staff.staffNo,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Type dropdown
                  Obx(() => SizedBox(
                        width: 115,
                        child: DropdownButtonFormField<String>(
                          value: row.selectedType.value,
                          isDense: true,
                          items: HrStaffAttendanceController.typeOptions
                              .map(
                                (t) => DropdownMenuItem<String>(
                                  value: t,
                                  child: Row(children: [
                                    _TypeDot(t),
                                    const SizedBox(width: 4),
                                    Text(
                                      HrStaffAttendanceController
                                          .typeLabels[t]!,
                                      style: GoogleFonts.inter(fontSize: 12),
                                    ),
                                  ]),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) row.selectedType.value = v;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Color(0xFF4F46E5), width: 1.5),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      )),
                ],
              ),
            ),

            // Note field
            Padding(
              padding:
                  const EdgeInsets.only(left: 64, right: 16, bottom: 8),
              child: sTextField(
                controller: row.noteCtrl,
                hint: 'Note (optional)',
              ),
            ),

            // Divider
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Type Dot
// ─────────────────────────────────────────────────────────────────────────────

class _TypeDot extends StatelessWidget {
  final String type;
  const _TypeDot(this.type);

  Color get _color {
    switch (type) {
      case 'P':
        return const Color(0xFF059669);
      case 'A':
        return const Color(0xFFDC2626);
      case 'L':
        return const Color(0xFFEA580C);
      case 'F':
        return const Color(0xFF8B5CF6);
      case 'H':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
        ),
      );
}
