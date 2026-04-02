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
  const Color(0xFF6366F1),
  const Color(0xFF8B5CF6),
  const Color(0xFFEC4899),
  const Color(0xFF14B8A6),
  const Color(0xFFF59E0B),
  const Color(0xFF3B82F6),
  const Color(0xFFEF4444),
  const Color(0xFF10B981),
];

Color _accentFor(String name) =>
    _accents[name.hashCode.abs() % _accents.length];

class NoticeBoardTab extends StatelessWidget {
  const NoticeBoardTab({super.key});

  CommunicationController get _c => Get.find<CommunicationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_c.noticeLoading.value && _c.notices.isEmpty) {
        return const SchoolLoader();
      }
      return RefreshIndicator(
        onRefresh: _c.loadNotices,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _c.showNoticeForm.value
                  ? _buildForm(context)
                  : _buildAddButton()),
              const SizedBox(height: 20),
              sectionHeader('Notices'),
              const SizedBox(height: 12),
              Obx(() {
                if (_c.notices.isEmpty) {
                  return sEmptyState(
                    'No notices yet.\nTap + Add Notice to create one.',
                    Icons.campaign_outlined,
                  );
                }
                return Column(
                  children: _c.notices
                      .map((n) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _NoticeCard(
                              notice: n,
                              onEdit: () => _c.startNoticeEdit(n),
                              onDelete: () => showDialog(
                                context: context,
                                builder: (_) => sDeleteDialog(
                                  context: context,
                                  message:
                                      'Delete "${n.title}"? This cannot be undone.',
                                  onConfirm: () => _c.deleteNotice(n.id),
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
        onTap: _c.startNoticeCreate,
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
              Text('Add Notice',
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
                  _c.isNoticeEditing
                      ? Icons.edit_rounded
                      : Icons.campaign_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _c.isNoticeEditing ? 'Edit Notice' : 'New Notice',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: _c.cancelNoticeForm,
              ),
            ],
          ),
          const SizedBox(height: 16),
          sFieldLabel('Title'),
          sTextField(controller: _c.noticeTitleCtrl, hint: 'Notice title'),
          const SizedBox(height: 14),
          sFieldLabel('Message'),
          sTextField(
            controller: _c.noticeMessageCtrl,
            hint: 'Notice message...',
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          sFieldLabel('Inform To (Roles)'),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _c.roles.map((r) {
                  final sel = _c.selectedRoles.contains(r.id);
                  return GestureDetector(
                    onTap: () => sel
                        ? _c.selectedRoles.remove(r.id)
                        : _c.selectedRoles.add(r.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: sel
                            ? const LinearGradient(colors: [_kPri, _kVio])
                            : null,
                        color: sel ? null : Colors.white,
                        border: Border.all(
                          color: sel
                              ? Colors.transparent
                              : _kPri.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: _kPri.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        r.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sFieldLabel('Notice Date'),
                    _datePicker(context, _c.noticeDate),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sFieldLabel('Publish Date'),
                    _datePicker(context, _c.publishDate),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() => Row(
                children: [
                  Switch(
                    value: _c.isPublished.value,
                    onChanged: (v) => _c.isPublished.value = v,
                    activeThumbColor: _kPri,
                  ),
                  const SizedBox(width: 8),
                  Text('Published',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _c.cancelNoticeForm,
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
                      label: _c.noticeSaving.value
                          ? 'Saving...'
                          : (_c.isNoticeEditing ? 'Update' : 'Create'),
                      loading: _c.noticeSaving.value,
                      onTap:
                          _c.noticeSaving.value ? null : () => _c.saveNotice(),
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

// ── Notice Card ──────────────────────────────────────────────────────────────

class _NoticeCard extends StatelessWidget {
  final NoticeBoard notice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoticeCard({
    required this.notice,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(notice.title);
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
                  child: const Icon(Icons.campaign_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (notice.noticeDate != null)
                        Text(
                          _fmtDate(notice.noticeDate),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                    ],
                  ),
                ),
                if (notice.isPublished)
                  sBadge('Published', const Color(0xFF16A34A))
                else
                  sBadge('Draft', const Color(0xFFD97706)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notice.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
            if (notice.informToLabels.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: notice.informToLabels
                    .map((label) => sBadge(label, accent))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                sIconBtn(Icons.edit_rounded, _kPri, onEdit),
                const SizedBox(width: 8),
                sIconBtn(
                    Icons.delete_outline_rounded, const Color(0xFFDC2626), onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(String? d) {
    if (d == null) return '';
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('dd MMM yyyy').format(dt) : d;
  }
}

// ── Shared gradient button ─────────────────────────────────────────────────

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
