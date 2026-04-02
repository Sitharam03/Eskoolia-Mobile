import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_staff_attendance_controller.dart';
import '_hr_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design constants
// ─────────────────────────────────────────────────────────────────────────────

const _kPri = Color(0xFF0EA5E9);
const _kSec = Color(0xFF0284C7);
const _kVio = Color(0xFF6366F1);

Color _accentFor(String name) {
  if (name.isEmpty) return _kPri;
  final code = name.codeUnitAt(0) % 6;
  const palette = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF7C3AED),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];
  return palette[code];
}

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
              return const SchoolLoader();
            }
            return RefreshIndicator(
              color: _kPri,
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
          colorScheme: ColorScheme.light(
            primary: _kPri,
            onPrimary: Colors.white,
            onSurface: const Color(0xFF111827),
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
        decoration: sCardDecoration,
        child: Column(
          children: [
            // Gradient header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kPri.withValues(alpha: 0.08),
                    _kVio.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  // Gradient icon container
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kPri, _kVio],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _kPri.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.calendar_today_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => Text(
                          c.selectedDate.value.isEmpty
                              ? 'Select Date'
                              : c.selectedDate.value,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        )),
                  ),
                  // Pick Date button
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kPri, _kVio],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _kPri.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_calendar_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Pick Date',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
            color: const Color(0xFF059669),
            count: c.presentCount,
            label: 'Present',
          ),
          _ChipData(
            color: const Color(0xFFDC2626),
            count: c.absentCount,
            label: 'Absent',
          ),
          _ChipData(
            color: const Color(0xFFEA580C),
            count: c.leaveCount,
            label: 'Leave',
          ),
          _ChipData(
            color: const Color(0xFF8B5CF6),
            count: c.halfDayCount,
            label: 'Half Day',
          ),
          _ChipData(
            color: const Color(0xFF0EA5E9),
            count: c.holidayCount,
            label: 'Holiday',
          ),
        ];
        return Row(
          children: chips
              .map((d) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            d.color.withValues(alpha: 0.12),
                            d.color.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: d.color.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          // Colored dot + count
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: d.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${d.count}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: d.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.label,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      });
}

class _ChipData {
  final Color color;
  final int count;
  final String label;
  const _ChipData(
      {required this.color, required this.count, required this.label});
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF059669).withValues(alpha: 0.10),
              const Color(0xFF059669).withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
              color: const Color(0xFF059669).withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check_circle_rounded,
                size: 16, color: Color(0xFF059669)),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFDC2626).withValues(alpha: 0.10),
              const Color(0xFFDC2626).withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.error_rounded,
                size: 16, color: Color(0xFFDC2626)),
          ),
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
        decoration: sCardDecoration,
        child: Column(
          children: [
            // Gradient header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _kPri.withValues(alpha: 0.08),
                    _kVio.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Gradient icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kPri, _kVio],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _kPri.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.people_alt_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Staff Attendance',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  // Staff count badge
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kVio.withValues(alpha: 0.12),
                              _kVio.withValues(alpha: 0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _kVio.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          '${c.attendanceRows.length} Staff',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _kVio,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                ],
              ),
            ),

            // Staff rows — individual cards
            Obx(() {
              if (c.attendanceRows.isEmpty) {
                return sEmptyState(
                    'No active staff', Icons.people_outline_rounded);
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Column(
                  children: List.generate(
                    c.attendanceRows.length,
                    (i) => _AttendanceRow(
                      row: c.attendanceRows[i],
                      index: i,
                    ),
                  ),
                ),
              );
            }),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: c.isSaving.value
                            ? LinearGradient(
                                colors: [
                                  _kPri.withValues(alpha: 0.6),
                                  _kVio.withValues(alpha: 0.6),
                                ],
                              )
                            : const LinearGradient(
                                colors: [_kPri, _kVio],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: c.isSaving.value
                            ? null
                            : [
                                BoxShadow(
                                  color: _kPri.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: MaterialButton(
                        onPressed: c.isSaving.value ? null : c.saveAttendance,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (c.isSaving.value)
                              sSavingIndicator()
                            else
                              const Icon(Icons.save_rounded,
                                  size: 18, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              c.isSaving.value
                                  ? 'Saving...'
                                  : 'Save Attendance',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
  final int index;
  const _AttendanceRow({required this.row, required this.index});

  Color get _typeColor {
    switch (row.selectedType.value) {
      case 'P':
        return const Color(0xFF22C55E);
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
  Widget build(BuildContext context) {
    final accent = _accentFor(row.staff.fullName);

    return Obx(() {
      final tColor = _typeColor;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, accent.withValues(alpha: 0.03)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top: avatar + name + status type selector ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  // Gradient avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accent, accent.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      row.staff.initials,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + staff no
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.staff.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row.staff.staffNo,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Middle: Type quick-select buttons ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: HrStaffAttendanceController.typeOptions
                    .map((t) {
                  final isSelected = row.selectedType.value == t;
                  final btnColor = _colorForType(t);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: () => row.selectedType.value = t,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(colors: [
                                    btnColor,
                                    btnColor.withValues(alpha: 0.8),
                                  ])
                                : null,
                            color: isSelected
                                ? null
                                : btnColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? btnColor.withValues(alpha: 0.5)
                                  : btnColor.withValues(alpha: 0.15),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          btnColor.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(
                                t,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : btnColor,
                                ),
                              ),
                              Text(
                                HrStaffAttendanceController.typeLabels[t]!,
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                          .withValues(alpha: 0.8)
                                      : btnColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // ── Bottom: Note field ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextField(
                controller: row.noteCtrl,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF111827)),
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF9CA3AF)),
                  prefixIcon: Icon(Icons.sticky_note_2_outlined,
                      size: 16,
                      color: accent.withValues(alpha: 0.4)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: accent.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: accent.withValues(alpha: 0.10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: accent.withValues(alpha: 0.10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'P':
        return const Color(0xFF22C55E);
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
}

