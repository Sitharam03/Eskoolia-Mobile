import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/school_loader.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/communication_controller.dart';
import '../models/communication_models.dart';

const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

final _accents = [
  const Color(0xFF14B8A6),
  const Color(0xFFF59E0B),
  const Color(0xFF8B5CF6),
  const Color(0xFFEC4899),
  const Color(0xFF3B82F6),
  const Color(0xFF10B981),
  const Color(0xFFEF4444),
  const Color(0xFF6366F1),
];

Color _accentFor(String name) =>
    _accents[name.hashCode.abs() % _accents.length];

class HolidayCalendarTab extends StatelessWidget {
  const HolidayCalendarTab({super.key});

  CommunicationController get _c => Get.find<CommunicationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_c.holidayLoading.value && _c.holidays.isEmpty) {
        return const SchoolLoader();
      }
      return RefreshIndicator(
        onRefresh: _c.loadHolidays,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Search ──────────────────────────────────────────────────
              sSearchBar(
                hint: 'Search holidays...',
                onChanged: (q) => _c.holidaySearch.value = q,
              ),
              const SizedBox(height: 16),

              // ── Form / Add button ───────────────────────────────────────
              Obx(() => _c.showHolidayForm.value
                  ? _buildForm(context)
                  : _buildAddButton()),
              const SizedBox(height: 20),

              // ── Holiday list ────────────────────────────────────────────
              sectionHeader('Holidays'),
              const SizedBox(height: 12),
              Obx(() {
                final list = _c.filteredHolidays;
                if (list.isEmpty) {
                  return sEmptyState(
                    'No holidays found.\nTap + Add Holiday to create one.',
                    Icons.event_rounded,
                  );
                }
                return Column(
                  children: list
                      .map((h) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HolidayCard(
                              holiday: h,
                              onEdit: () => _c.startHolidayEdit(h),
                              onDelete: () => showDialog(
                                context: context,
                                builder: (_) => sDeleteDialog(
                                  context: context,
                                  message:
                                      'Delete "${h.title}"? This cannot be undone.',
                                  onConfirm: () => _c.deleteHoliday(h.id),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddButton() => GestureDetector(
        onTap: _c.startHolidayCreate,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_kPri, _kVio]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _kPri.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Add Holiday',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
        ),
      );

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: sCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kPri, _kVio]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _c.isHolidayEditing
                      ? Icons.edit_rounded
                      : Icons.event_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _c.isHolidayEditing ? 'Edit Holiday' : 'New Holiday',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: _c.cancelHolidayForm,
              ),
            ],
          ),
          const SizedBox(height: 16),
          sFieldLabel('Holiday Title'),
          sTextField(
              controller: _c.holidayTitleCtrl, hint: 'e.g. Winter Break'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sFieldLabel('Start Date'),
                    _datePicker(context, _c.holidayStartDate),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sFieldLabel('End Date'),
                    _datePicker(context, _c.holidayEndDate),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() => Row(
                children: [
                  Switch(
                    value: _c.holidayIsActive.value,
                    onChanged: (v) => _c.holidayIsActive.value = v,
                    activeThumbColor: _kPri,
                  ),
                  const SizedBox(width: 8),
                  Text('Active',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _c.cancelHolidayForm,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _kPri.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _gradientButton(
                      label: _c.holidaySaving.value
                          ? 'Saving...'
                          : (_c.isHolidayEditing ? 'Update' : 'Create'),
                      loading: _c.holidaySaving.value,
                      onTap: _c.holidaySaving.value
                          ? null
                          : () => _c.saveHoliday(),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePicker(BuildContext context, Rx<DateTime?> date) {
    return Obx(() => GestureDetector(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: date.value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2040),
            );
            if (d != null) date.value = d;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              border: Border.all(color: _kPri.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date.value != null
                        ? DateFormat('dd MMM yyyy').format(date.value!)
                        : 'Select date',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: date.value != null
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                          colors: [_kPri, _kVio])
                      .createShader(b),
                  child: const Icon(Icons.calendar_today_rounded,
                      size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ));
  }
}

// ── Holiday Card ─────────────────────────────────────────────────────────────

class _HolidayCard extends StatelessWidget {
  final HolidayCalendar holiday;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HolidayCard({
    required this.holiday,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(holiday.title);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, accent.withValues(alpha: 0.05)],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    holiday.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                if (holiday.isActive)
                  sBadge('Active', const Color(0xFF16A34A))
                else
                  sBadge('Inactive', const Color(0xFF9CA3AF)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.06),
                    accent.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range_rounded,
                      size: 18, color: accent.withValues(alpha: 0.7)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_fmtDate(holiday.startDate)}  -  ${_fmtDate(holiday.endDate)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                sIconBtn(Icons.edit_rounded, _kPri, onEdit),
                const SizedBox(width: 8),
                sIconBtn(Icons.delete_outline_rounded,
                    const Color(0xFFDC2626), onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String? d) {
    if (d == null) return '—';
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yyyy').format(dt) : d;
  }
}

// ── Gradient button ─────────────────────────────────────────────────────────

Widget _gradientButton({
  required String label,
  bool loading = false,
  VoidCallback? onTap,
}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kPri, _kVio]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _kPri.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(label,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
        ),
      ),
    );
