import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/library_issue_controller.dart';
import '../models/library_models.dart';
import '_library_nav_tabs.dart';
import '../../../core/widgets/school_loader.dart';

class LibraryIssueView extends StatelessWidget {
  const LibraryIssueView({super.key});

  LibraryIssueController get _c => Get.find<LibraryIssueController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Library',
      body: Column(
        children: [
          const LibraryNavTabs(activeRoute: AppRoutes.libraryIssues),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const SchoolLoader();
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: _c.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    children: [
                      _IssueFormCard(c: _c),
                      Obx(() {
                        if (_c.errorMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ErrorBanner(msg: _c.errorMsg.value),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      const SizedBox(height: 12),
                      _FilterCard(c: _c),
                      const SizedBox(height: 16),
                      _IssueList(c: _c),
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

// ── Issue Form ────────────────────────────────────────────────────────────────

class _IssueFormCard extends StatelessWidget {
  final LibraryIssueController c;
  const _IssueFormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Issue Book'),
        const SizedBox(height: 12),
        Obx(() => Column(children: [
              sFieldLabel('Book'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedBookId.value,
                hint: 'Select Book',
                items: c.books
                    .map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(
                              '${b.title} (${b.availableQuantity}/${b.quantity})',
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => c.selectedBookId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Member'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedMemberId.value,
                hint: 'Select Member',
                items: c.members
                    .map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(c.memberLabel(m.id),
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => c.selectedMemberId.value = v,
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Issue Date'),
                        const SizedBox(height: 6),
                        _DatePicker(
                          value: c.issueDate.value,
                          onPicked: (v) => c.issueDate.value = v,
                        ),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Due Date *'),
                        const SizedBox(height: 6),
                        _DatePicker(
                          value: c.dueDate.value,
                          hint: 'Select date',
                          onPicked: (v) => c.dueDate.value = v,
                        ),
                      ]),
                ),
              ]),
            ])),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton.icon(
                onPressed: c.isSaving.value ? null : c.issueBook,
                icon: c.isSaving.value
                    ? sSavingIndicator()
                    : const Icon(Icons.library_books_rounded, size: 18),
                label: Text(c.isSaving.value ? 'Issuing…' : 'Issue Book',
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

class _DatePicker extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onPicked;
  const _DatePicker(
      {required this.value,
      this.hint = '',
      required this.onPicked});

  @override
  State<_DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<_DatePicker> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _ctrl.text = widget.value;
    }
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
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _ctrl.text = formatted;
      widget.onPicked(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return sTextField(
      controller: _ctrl,
      hint: widget.hint.isNotEmpty ? widget.hint : 'YYYY-MM-DD',
      readOnly: true,
      onTap: _pick,
      suffixIcon: const Icon(Icons.calendar_today_rounded,
          size: 18, color: Color(0xFF9CA3AF)),
    );
  }
}

// ── Filter ────────────────────────────────────────────────────────────────────

class _FilterCard extends StatelessWidget {
  final LibraryIssueController c;
  const _FilterCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        sectionHeader('Filter'),
        const SizedBox(height: 12),
        Obx(() => Column(children: [
              sFieldLabel('Status'),
              const SizedBox(height: 6),
              sDropdown<String>(
                value: c.statusFilter.value.isEmpty ? null : c.statusFilter.value,
                hint: 'All Status',
                items: const [
                  DropdownMenuItem(value: 'issued', child: Text('Issued')),
                  DropdownMenuItem(value: 'returned', child: Text('Returned')),
                  DropdownMenuItem(value: 'lost', child: Text('Lost')),
                ],
                onChanged: (v) => c.statusFilter.value = v ?? '',
              ),
              const SizedBox(height: 10),
              Row(children: [
                Checkbox(
                  value: c.showOverdueOnly.value,
                  onChanged: (v) => c.showOverdueOnly.value = v ?? false,
                  activeColor: const Color(0xFFDC2626),
                ),
                Text('Show overdue only',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF374151))),
                const Spacer(),
                TextButton.icon(
                  onPressed: _c(context).load,
                  icon: const Icon(Icons.refresh_rounded,
                      size: 16, color: Color(0xFF4F46E5)),
                  label: Text('Refresh',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ])),
      ]),
    );
  }

  LibraryIssueController _c(BuildContext context) =>
      Get.find<LibraryIssueController>();
}

// ── Issue List ────────────────────────────────────────────────────────────────

class _IssueList extends StatelessWidget {
  final LibraryIssueController c;
  const _IssueList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = c.filteredIssues;
      if (rows.isEmpty) {
        return sEmptyState('No issues found', Icons.library_books_outlined);
      }
      return Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            sectionHeader('Issues'),
            Text('${rows.length} records',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF6B7280))),
          ]),
          const SizedBox(height: 12),
          ...rows.map((issue) => _IssueRow(issue: issue, c: c)),
        ]),
      );
    });
  }
}

class _IssueRow extends StatelessWidget {
  final BookIssue issue;
  final LibraryIssueController c;
  const _IssueRow({required this.issue, required this.c});

  Color get _statusColor {
    switch (issue.status) {
      case 'returned':
        return const Color(0xFF059669);
      case 'lost':
        return const Color(0xFFDC2626);
      default:
        return issue.isOverdue
            ? const Color(0xFFDC2626)
            : const Color(0xFF4F46E5);
    }
  }

  String get _statusLabel {
    if (issue.status == 'issued' && issue.isOverdue) return 'Overdue';
    return issue.status[0].toUpperCase() + issue.status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: issue.isOverdue
            ? const Color(0xFFDC2626).withValues(alpha: 0.04)
            : const Color(0xFFF9FAFB),
        border: Border.all(
            color: issue.isOverdue
                ? const Color(0xFFDC2626).withValues(alpha: 0.2)
                : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(c.bookLabel(issue.bookId),
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
          ),
          sBadge(_statusLabel, _statusColor),
        ]),
        const SizedBox(height: 6),
        Text(c.memberLabel(issue.memberId),
            style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF6B7280))),
        const SizedBox(height: 6),
        Wrap(spacing: 16, runSpacing: 4, children: [
          _DateChip(
              label: 'Issued', value: issue.issueDate, color: const Color(0xFF4F46E5)),
          _DateChip(
              label: 'Due',
              value: issue.dueDate,
              color: issue.isOverdue
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFEA580C)),
          if (issue.returnDate != null)
            _DateChip(
                label: 'Returned',
                value: issue.returnDate!,
                color: const Color(0xFF059669)),
          if (double.tryParse(issue.fineAmount) != null &&
              double.parse(issue.fineAmount) > 0)
            _DateChip(
                label: 'Fine',
                value: issue.fineAmount,
                color: const Color(0xFFDC2626)),
        ]),
        if (issue.status == 'issued') ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => c.markReturned(issue),
              icon: const Icon(Icons.assignment_return_rounded, size: 16),
              label: Text('Mark Returned',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF059669),
                side: const BorderSide(color: Color(0xFF059669)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DateChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label: ',
          style: GoogleFonts.inter(
              fontSize: 12, color: const Color(0xFF9CA3AF))),
      Text(value,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]);
  }
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: Color(0xFFDC2626), size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFFDC2626)))),
      ]),
    );
  }
}
