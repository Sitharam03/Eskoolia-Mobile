import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_payroll_controller.dart';
import '../models/hr_models.dart';
import '_hr_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design constants
// ─────────────────────────────────────────────────────────────────────────────

const _kPri = Color(0xFF0EA5E9);
const _kSec = Color(0xFF0284C7);
const _kVio = Color(0xFF6366F1);

const _kSuccess = Color(0xFF22C55E);
const _kDanger = Color(0xFFDC2626);

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

class HrPayrollView extends StatelessWidget {
  const HrPayrollView({super.key});

  HrPayrollController get c => Get.find<HrPayrollController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Human Resource',
      body: Column(children: [
        const HrNavTabs(activeRoute: AppRoutes.hrPayroll),
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
                    _SummaryBanner(c: c),
                    const SizedBox(height: 16),
                    _StatusFilterRow(c: c),
                    const SizedBox(height: 16),
                    _GenerateFormCard(c: c),
                    const SizedBox(height: 16),
                    _PayrollList(c: c),
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
// Summary Banner
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final HrPayrollController c;
  const _SummaryBanner({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kPri, _kVio, Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kPri.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 40,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payroll Overview',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${c.records.length} total records',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // Metric tiles on white overlay - Row 1
                Row(children: [
                  _MetricTile(
                    label: 'Basic Salary',
                    value: c.totalBasic.value,
                    accentColor: _kPri,
                  ),
                  const SizedBox(width: 10),
                  _MetricTile(
                    label: 'Allowance',
                    value: c.totalAllowance.value,
                    accentColor: _kSuccess,
                  ),
                ]),
                const SizedBox(height: 10),

                // Row 2
                Row(children: [
                  _MetricTile(
                    label: 'Deduction',
                    value: c.totalDeduction.value,
                    accentColor: _kDanger,
                  ),
                  const SizedBox(width: 10),
                  _MetricTile(
                    label: 'Net Salary',
                    value: c.totalNet.value,
                    accentColor: const Color(0xFFF59E0B),
                    highlighted: true,
                  ),
                ]),
              ],
            ),
          ],
        ),
      ));
}

class _MetricTile extends StatelessWidget {
  final String label;
  final double value;
  final Color accentColor;
  final bool highlighted;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accentColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: highlighted ? 0.22 : 0.15),
            borderRadius: BorderRadius.circular(14),
            border: highlighted
                ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(children: [
            // Accent bar on left
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Filter Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatusFilterRow extends StatelessWidget {
  final HrPayrollController c;
  const _StatusFilterRow({required this.c});

  static const _icons = <String, IconData>{
    '': Icons.all_inbox_rounded,
    'draft': Icons.edit_note_rounded,
    'processed': Icons.sync_rounded,
    'paid': Icons.check_circle_rounded,
  };

  @override
  Widget build(BuildContext context) => Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: HrPayrollController.statusFilters.map((status) {
            final selected = c.selectedStatusFilter.value == status;
            final label = HrPayrollController.statusLabels[status] ?? status;
            return GestureDetector(
              onTap: () => c.selectedStatusFilter.value = status,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [_kPri, _kVio],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: selected ? null : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(22),
                  border: selected
                      ? null
                      : Border.all(color: _kPri.withValues(alpha: 0.12)),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _kPri.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    _icons[status] ?? Icons.filter_list_rounded,
                    size: 14,
                    color:
                        selected ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          selected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                ]),
              ),
            );
          }).toList(),
        ),
      ));
}

// ─────────────────────────────────────────────────────────────────────────────
// Generate Payroll Form Card
// ─────────────────────────────────────────────────────────────────────────────

class _GenerateFormCard extends StatelessWidget {
  final HrPayrollController c;
  const _GenerateFormCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        child: Column(children: [
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
              border:
                  const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
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
                child: const Icon(Icons.calculate_rounded,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Payroll',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Create a new payroll record',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),

          // Form fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Staff
                    sFieldLabel('Staff Member *'),
                    const SizedBox(height: 6),
                    sDropdown<int>(
                      value: c.selectedStaffId.value,
                      hint: 'Select staff member',
                      items: c.activeStaff
                          .map((s) => DropdownMenuItem<int>(
                              value: s.id, child: Text(s.fullName)))
                          .toList(),
                      onChanged: (v) {
                        c.selectedStaffId.value = v;
                        c.prefillSalary();
                      },
                    ),
                    const SizedBox(height: 14),

                    // Month & Year
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Month'),
                            const SizedBox(height: 6),
                            sTextField(
                              controller: c.monthCtrl,
                              hint: '1 - 12',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Year'),
                            const SizedBox(height: 6),
                            sTextField(
                              controller: c.yearCtrl,
                              hint: '2025',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    // Basic & Allowance
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Basic Salary'),
                            const SizedBox(height: 6),
                            sTextField(
                              controller: c.basicSalaryCtrl,
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Allowance'),
                            const SizedBox(height: 6),
                            sTextField(
                              controller: c.allowanceCtrl,
                              hint: '0.00',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    // Deduction
                    sFieldLabel('Deduction'),
                    const SizedBox(height: 6),
                    sTextField(
                      controller: c.deductionCtrl,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 14),

                    // Net preview
                    _NetPreviewCard(c: c),
                    const SizedBox(height: 14),

                    // Error banner
                    if (c.errorMsg.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _kDanger.withValues(alpha: 0.10),
                                _kDanger.withValues(alpha: 0.04),
                              ],
                            ),
                            border: Border.all(
                                color: _kDanger.withValues(alpha: 0.25)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _kDanger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.error_rounded,
                                  size: 16, color: _kDanger),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.errorMsg.value,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF991B1B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),

                    // Generate button - gradient
                    SizedBox(
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
                          onPressed: c.isSaving.value ? null : c.save,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (c.isSaving.value)
                                sSavingIndicator()
                              else
                                const Icon(Icons.send_rounded,
                                    size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                c.isSaving.value
                                    ? 'Generating...'
                                    : 'Generate Payroll',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Net Salary Preview
// ─────────────────────────────────────────────────────────────────────────────

class _NetPreviewCard extends StatefulWidget {
  final HrPayrollController c;
  const _NetPreviewCard({required this.c});

  @override
  State<_NetPreviewCard> createState() => _NetPreviewCardState();
}

class _NetPreviewCardState extends State<_NetPreviewCard> {
  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.c.basicSalaryCtrl.addListener(_rebuild);
    widget.c.allowanceCtrl.addListener(_rebuild);
    widget.c.deductionCtrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.c.basicSalaryCtrl.removeListener(_rebuild);
    widget.c.allowanceCtrl.removeListener(_rebuild);
    widget.c.deductionCtrl.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basic = double.tryParse(widget.c.basicSalaryCtrl.text) ?? 0;
    final allow = double.tryParse(widget.c.allowanceCtrl.text) ?? 0;
    final deduct = double.tryParse(widget.c.deductionCtrl.text) ?? 0;
    final net = basic + allow - deduct;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kSuccess.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: _kSuccess.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        // Gradient accent strip on left
        Container(
          width: 5,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kSuccess, Color(0xFF16A34A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Net value
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Net Salary',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  net.toStringAsFixed(2),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _kSuccess,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Breakdown column with colored indicators
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _BreakLine('+', 'Basic', basic, _kPri),
              const SizedBox(height: 4),
              _BreakLine('+', 'Allow.', allow, _kSuccess),
              const SizedBox(height: 4),
              _BreakLine('-', 'Deduct.', deduct, _kDanger),
            ],
          ),
        ),
      ]),
    );
  }
}

class _BreakLine extends StatelessWidget {
  final String sign;
  final String label;
  final double value;
  final Color color;
  const _BreakLine(this.sign, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$sign $label',
            style: GoogleFonts.inter(
                fontSize: 10, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 4),
          Text(
            value.toStringAsFixed(0),
            style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Payroll Records List
// ─────────────────────────────────────────────────────────────────────────────

class _PayrollList extends StatelessWidget {
  final HrPayrollController c;
  const _PayrollList({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        // ignore: unused_local_variable
        final _ = c.records.length;
        final records = c.filtered;
        if (records.isEmpty) {
          return sEmptyState(
              'No payroll records', Icons.calculate_outlined);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionHeader('Payroll Records'),
                Container(
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
                    border:
                        Border.all(color: _kVio.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    '${records.length} records',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _kVio,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...records.map((r) => _PayrollCard(record: r, c: c)),
          ],
        );
      });
}

// ─────────────────────────────────────────────────────────────────────────────
// Payroll Card
// ─────────────────────────────────────────────────────────────────────────────

class _PayrollCard extends StatelessWidget {
  final PayrollRecord record;
  final HrPayrollController c;
  const _PayrollCard({required this.record, required this.c});

  String get _initials {
    final parts = record.staffName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color get _accent => _accentFor(record.staffName);

  Color get _statusColor {
    switch (record.status) {
      case 'paid':
        return _kSuccess;
      case 'processed':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, accent.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle bottom-right
          Positioned(
            bottom: -15,
            right: -15,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Column(children: [
            // Top: avatar + name + status
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(children: [
                // Gradient avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + month badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.staffName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Month badge gradient pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kPri.withValues(alpha: 0.12),
                              _kVio.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _kPri.withValues(alpha: 0.12)),
                        ),
                        child: Text(
                          '${record.monthName} ${record.payrollYear}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _kPri,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status pill
                _StatusPill(status: record.status),
              ]),
            ),

            // Gradient divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.0),
                    accent.withValues(alpha: 0.12),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),

            // Salary breakdown row - 4 mini cells
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                _AmountCell(
                    label: 'Basic',
                    value: record.basicSalary,
                    color: _kPri),
                _AmountCell(
                    label: 'Allowance',
                    value: record.allowance,
                    color: _kSuccess),
                _AmountCell(
                    label: 'Deduction',
                    value: record.deduction,
                    color: _kDanger),
                _AmountCell(
                    label: 'Net',
                    value: record.netSalary,
                    color: _kVio,
                    bold: true),
              ]),
            ),

            // Action row
            if (record.status != 'paid')
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF22C55E).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      onPressed: () => c.markPaid(record.id),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Mark as Paid',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 15, color: _kSuccess),
                  const SizedBox(width: 6),
                  Text(
                    'Payment completed',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _kSuccess,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
              ),
          ]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  Color get _color {
    switch (status) {
      case 'paid':
        return _kSuccess;
      case 'processed':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get _label => status.isEmpty
      ? 'Draft'
      : '${status[0].toUpperCase()}${status.substring(1)}';

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _color.withValues(alpha: 0.15),
              _color.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ]),
      );
}

class _AmountCell extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;
  const _AmountCell(
      {required this.label,
      required this.value,
      required this.color,
      this.bold = false});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.03),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Text(
              value.toStringAsFixed(2),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
}
