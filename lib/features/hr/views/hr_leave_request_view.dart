import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/hr_leave_request_controller.dart';
import '../models/hr_models.dart';
import '_hr_nav_tabs.dart';

class HrLeaveRequestView extends StatelessWidget {
  const HrLeaveRequestView({super.key});
  HrLeaveRequestController get _c => Get.find<HrLeaveRequestController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Human Resource',
      body: Column(children: [
        const HrNavTabs(activeRoute: AppRoutes.hrLeaveRequests),
        Expanded(child: Obx(() {
          if (_c.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
          }
          return RefreshIndicator(
            color: const Color(0xFF4F46E5),
            onRefresh: _c.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(children: [
                _StatsRow(c: _c),
                const SizedBox(height: 14),
                _FormCard(c: _c),
                Obx(() => _c.errorMsg.value.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ErrorBanner(msg: _c.errorMsg.value))
                    : const SizedBox.shrink()),
                const SizedBox(height: 16),
                _RequestList(c: _c),
              ]),
            ),
          );
        })),
      ]),
    );
  }
}

// ── Stats ─────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final HrLeaveRequestController c;
  const _StatsRow({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final total = c.requests.length;
        final pending =
            c.requests.where((r) => r.status == 'pending').length;
        final approved =
            c.requests.where((r) => r.status == 'approved').length;
        return Row(children: [
          _Stat(
            value: '$total',
            label: 'Total',
            color: const Color(0xFF4F46E5),
            icon: Icons.event_note_rounded,
          ),
          const SizedBox(width: 8),
          _Stat(
            value: '$pending',
            label: 'Pending',
            color: const Color(0xFFEA580C),
            icon: Icons.pending_rounded,
          ),
          const SizedBox(width: 8),
          _Stat(
            value: '$approved',
            label: 'Approved',
            color: const Color(0xFF059669),
            icon: Icons.check_circle_rounded,
          ),
        ]);
      });
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
      );
}

// ── Form Card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final HrLeaveRequestController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) => Container(
        decoration: sCardDecoration,
        clipBehavior: Clip.hardEdge,
        child: Obx(() => Column(children: [
              _FormHeader(
                icon: c.editingId.value != null
                    ? Icons.edit_rounded
                    : Icons.add_circle_outline_rounded,
                title: c.editingId.value != null
                    ? 'Edit Leave Request'
                    : 'Apply for Leave',
                subtitle: 'Submit a leave request for approval',
                onCancel: c.editingId.value != null ? c.cancelEdit : null,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave Type dropdown (required)
                    sFieldLabel('Leave Type *'),
                    const SizedBox(height: 6),
                    Obx(() => sDropdown<int>(
                          value: c.selectedLeaveTypeId.value,
                          hint: 'Select leave type',
                          items: c.leaveTypes
                              .map((lt) => DropdownMenuItem<int>(
                                    value: lt.id,
                                    child: Text(lt.name,
                                        style: GoogleFonts.inter(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (v) => c.selectedLeaveTypeId.value = v,
                        )),

                    const SizedBox(height: 14),

                    // Date pickers row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDateField(
                              context, 'From Date *', c.fromDateCtrl),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDateField(
                              context, 'To Date *', c.toDateCtrl),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Reason textarea (optional)
                    sFieldLabel('Reason (optional)'),
                    const SizedBox(height: 6),
                    sTextField(
                      controller: c.reasonCtrl,
                      hint: 'Describe the reason for leave…',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Save button
                    Obx(() => _SaveBtn(
                          isSaving: c.isSaving.value,
                          isEditing: c.editingId.value != null,
                          onPressed: c.save,
                        )),
                  ],
                ),
              ),
            ])),
      );

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      sFieldLabel(label),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
              data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4F46E5))),
              child: child!,
            ),
          );
          if (picked != null) {
            ctrl.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
        child: AbsorbPointer(
          child: sTextField(
            controller: ctrl,
            hint: 'YYYY-MM-DD',
            suffixIcon: const Icon(Icons.calendar_today_rounded,
                size: 18, color: Color(0xFF9CA3AF)),
          ),
        ),
      ),
    ]);
  }
}

// ── Request List ──────────────────────────────────────────────────────────────

class _RequestList extends StatelessWidget {
  final HrLeaveRequestController c;
  const _RequestList({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
        final items = c.requests;
        if (items.isEmpty) {
          return sEmptyState(
              'No leave requests found', Icons.event_note_outlined);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ListHeader(title: 'Leave Requests', count: items.length),
          const SizedBox(height: 10),
          ...items.map((r) => _RequestCard(
                request: r,
                onEdit: () => c.startEdit(r),
                onDelete: () => showDialog(
                  context: context,
                  builder: (_) => sDeleteDialog(
                    context: context,
                    message:
                        'Delete leave request for "${r.leaveTypeName}"?',
                    onConfirm: () => c.delete(r.id),
                  ),
                ),
              )),
        ]);
      });
}

class _RequestCard extends StatelessWidget {
  final LeaveRequest request;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RequestCard({
    required this.request,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _accentColor {
    switch (request.status) {
      case 'approved':
        return const Color(0xFF059669);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFEA580C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final isPending = request.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: accent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.event_note_rounded,
                      size: 22,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leave type name (bold)
                        Text(
                          request.leaveTypeName.isNotEmpty
                              ? request.leaveTypeName
                              : '—',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 3),

                        // Date range
                        Row(children: [
                          const Icon(Icons.date_range_rounded,
                              size: 12, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            '${request.fromDate} → ${request.toDate}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ]),

                        // Staff name (if present)
                        if (request.staffName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.person_outline_rounded,
                                size: 12, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Text(
                              request.staffName,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ]),
                        ],

                        const SizedBox(height: 5),

                        // Status badge
                        sBadge(request.statusLabel, accent),

                        // Reason (italic grey)
                        if (request.reason.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            request.reason,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action buttons — only for pending
                  if (isPending)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionBtn(
                          icon: Icons.edit_rounded,
                          color: const Color(0xFF0EA5E9),
                          onTap: onEdit,
                        ),
                        const SizedBox(height: 6),
                        _ActionBtn(
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFDC2626),
                          onTap: onDelete,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared Private Widgets ─────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onCancel;
  const _FormHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
          border: const Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          if (onCancel != null)
            GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
        ]),
      );
}

class _SaveBtn extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onPressed;
  const _SaveBtn({
    required this.isSaving,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : onPressed,
          icon: isSaving
              ? sSavingIndicator()
              : Icon(
                  isEditing ? Icons.update_rounded : Icons.send_rounded,
                  size: 18,
                ),
          label: Text(
            isSaving
                ? 'Submitting…'
                : (isEditing ? 'Update Request' : 'Submit Request'),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      );
}

class _ListHeader extends StatelessWidget {
  final String title;
  final int count;
  const _ListHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        sectionHeader(title),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count records',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF4F46E5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: color),
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withValues(alpha: 0.08),
          border: Border.all(
            color: const Color(0xFFDC2626).withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
        ]),
      );
}
