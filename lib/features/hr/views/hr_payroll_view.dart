import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_payroll_controller.dart';
import '../models/hr_models.dart';
import '_hr_nav_tabs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Colour constants
// ─────────────────────────────────────────────────────────────────────────────

const _kPrimary = Color(0xFF4F46E5);
const _kSuccess = Color(0xFF059669);
const _kDanger = Color(0xFFDC2626);
const _kInfo = Color(0xFF0EA5E9);
const _kPurple = Color(0xFF7C3AED);

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
              return const Center(
                child: CircularProgressIndicator(color: _kPrimary),
              );
            }
            return RefreshIndicator(
              color: _kPrimary,
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
// Summary Banner  (gradient + 2×2 metric grid)
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final HrPayrollController c;
  const _SummaryBanner({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kPrimary, _kPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(11),
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
                      style: GoogleFonts.inter(
                        fontSize: 15,
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
            const SizedBox(height: 14),

            // ── Row 1: Basic | Allowance ──────────────────────────────────
            Row(children: [
              _MetricTile(
                label: 'Basic Salary',
                value: c.totalBasic.value,
                icon: Icons.payments_rounded,
                iconColor: Colors.white,
                iconBg: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'Allowance',
                value: c.totalAllowance.value,
                icon: Icons.add_circle_outline_rounded,
                iconColor: const Color(0xFF86EFAC),
                iconBg: const Color(0xFF86EFAC).withValues(alpha: 0.2),
                valueColor: const Color(0xFF86EFAC),
              ),
            ]),
            const SizedBox(height: 10),

            // ── Row 2: Deduction | Net ────────────────────────────────────
            Row(children: [
              _MetricTile(
                label: 'Deduction',
                value: c.totalDeduction.value,
                icon: Icons.remove_circle_outline_rounded,
                iconColor: const Color(0xFFFCA5A5),
                iconBg: const Color(0xFFFCA5A5).withValues(alpha: 0.2),
                valueColor: const Color(0xFFFCA5A5),
              ),
              const SizedBox(width: 10),
              _MetricTile(
                label: 'Net Salary',
                value: c.totalNet.value,
                icon: Icons.monetization_on_rounded,
                iconColor: const Color(0xFFFDE68A),
                iconBg: const Color(0xFFFDE68A).withValues(alpha: 0.2),
                valueColor: const Color(0xFFFDE68A),
                highlighted: true,
              ),
            ]),
          ],
        ),
      ));
}

class _MetricTile extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color? valueColor;
  final bool highlighted;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.valueColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: highlighted
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: highlighted
                ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(8)),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: valueColor ?? Colors.white,
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
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? _kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected ? _kPrimary : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                    style: GoogleFonts.inter(
                      fontSize: 13,
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
          // ── Card header ──────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F4FF),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.calculate_rounded,
                    size: 18, color: _kPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Payroll',
                      style: GoogleFonts.inter(
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

          // ── Form fields ─────────────────────────────────────────────────
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

                    // Month & Year — side by side
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sFieldLabel('Month'),
                            const SizedBox(height: 6),
                            sTextField(
                              controller: c.monthCtrl,
                              hint: '1 – 12',
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

                    // Basic & Allowance — side by side
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

                    // Deduction — full width
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

                    // Net preview (reactive)
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
                            color: _kDanger.withValues(alpha: 0.08),
                            border: Border.all(
                                color: _kDanger.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_rounded,
                                size: 18, color: _kDanger),
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

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            c.isSaving.value ? null : c.save,
                        icon: c.isSaving.value
                            ? sSavingIndicator()
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          c.isSaving.value
                              ? 'Generating…'
                              : 'Generate Payroll',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _kPrimary.withValues(alpha: 0.6),
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
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
// Net Salary Preview  (stateful — reacts to text controller changes)
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _kSuccess.withValues(alpha: 0.08),
            _kSuccess.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _kSuccess.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(children: [
        // ── Icon ──────────────────────────────────────────────────────────
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _kSuccess.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.account_balance_rounded,
              size: 22, color: _kSuccess),
        ),
        const SizedBox(width: 14),

        // ── Net value ─────────────────────────────────────────────────────
        Expanded(
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
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kSuccess,
                ),
              ),
            ],
          ),
        ),

        // ── Breakdown column ──────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _BreakLine('+', 'Basic', basic, _kPrimary),
            const SizedBox(height: 3),
            _BreakLine('+', 'Allow.', allow, _kSuccess),
            const SizedBox(height: 3),
            _BreakLine('−', 'Deduct.', deduct, _kDanger),
          ],
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
                    color: _kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${records.length} records',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _kPrimary,
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

  // Generate initials from staff name
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

  // Deterministic gradient from first char code
  List<Color> get _avatarGradient {
    final gradients = [
      [_kPrimary, _kPurple],
      [_kInfo, const Color(0xFF0369A1)],
      [_kSuccess, const Color(0xFF0D9488)],
      [const Color(0xFFEA580C), _kDanger],
      [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
    ];
    final idx = record.staffName.isNotEmpty
        ? record.staffName.codeUnitAt(0) % gradients.length
        : 0;
    return gradients[idx];
  }

  Color get _statusColor {
    switch (record.status) {
      case 'paid':
        return _kSuccess;
      case 'processed':
        return _kInfo;
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(children: [
          // ── Top: avatar + name + status ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(children: [
              // Gradient avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _avatarGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: GoogleFonts.inter(
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
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${record.monthName} ${record.payrollYear}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),

              // Status badge
              _StatusPill(status: record.status),
            ]),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          Container(height: 1, color: const Color(0xFFF3F4F6)),

          // ── Salary breakdown row ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              _AmountCell(
                  label: 'Basic',
                  value: record.basicSalary,
                  color: _kPrimary),
              const _CellDivider(),
              _AmountCell(
                  label: 'Allowance',
                  value: record.allowance,
                  color: _kSuccess),
              const _CellDivider(),
              _AmountCell(
                  label: 'Deduction',
                  value: record.deduction,
                  color: _kDanger),
              const _CellDivider(),
              _AmountCell(
                  label: 'Net',
                  value: record.netSalary,
                  color: _kInfo,
                  bold: true),
            ]),
          ),

          // ── Action row ───────────────────────────────────────────────────
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          if (record.status != 'paid')
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () => c.markPaid(record.id),
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 16),
                  label: Text(
                    'Mark as Paid',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kSuccess,
                    side: const BorderSide(color: _kSuccess, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(children: [
                Icon(Icons.check_circle_rounded,
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
      );
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
        return _kInfo;
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
          color: _color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withValues(alpha: 0.3)),
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
            style: GoogleFonts.inter(
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
        child: Column(children: [
          Text(
            value.toStringAsFixed(2),
            style: GoogleFonts.inter(
              fontSize: 12,
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
              fontSize: 10,
              color: const Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ]),
      );
}

class _CellDivider extends StatelessWidget {
  const _CellDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 28,
        color: const Color(0xFFF3F4F6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
      );
}
