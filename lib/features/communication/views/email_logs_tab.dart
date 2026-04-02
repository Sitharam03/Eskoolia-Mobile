import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/school_loader.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/communication_controller.dart';
import '../models/communication_models.dart';

const _kPri = Color(0xFF6366F1);
final _accents = [
  const Color(0xFF3B82F6),
  const Color(0xFF8B5CF6),
  const Color(0xFF14B8A6),
  const Color(0xFFF59E0B),
  const Color(0xFFEC4899),
  const Color(0xFF6366F1),
  const Color(0xFF10B981),
  const Color(0xFFEF4444),
];

Color _accentFor(String name) =>
    _accents[name.hashCode.abs() % _accents.length];

class EmailLogsTab extends StatelessWidget {
  const EmailLogsTab({super.key});

  CommunicationController get _c => Get.find<CommunicationController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_c.logsLoading.value && _c.emailLogs.isEmpty) {
        return const SchoolLoader();
      }
      return RefreshIndicator(
        onRefresh: _c.loadEmailLogs,
        child: _c.emailLogs.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: sEmptyState(
                  'No email logs yet.\nSent emails will appear here.',
                  Icons.history_rounded,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _c.emailLogs.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          sectionHeader('Email Logs'),
                          const Spacer(),
                          Text(
                            '${_c.emailLogs.length} entries',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          sRefreshButton(() => _c.loadEmailLogs()),
                        ],
                      ),
                    );
                  }
                  final log = _c.emailLogs[i - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EmailLogCard(log: log),
                  );
                },
              ),
      );
    });
  }
}

// ── Email Log Card ──────────────────────────────────────────────────────────

class _EmailLogCard extends StatelessWidget {
  final EmailSmsLog log;
  const _EmailLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(log.title);
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
                  child: const Icon(Icons.email_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        _fmtDate(log.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                sBadge(
                  log.sendThrough.toUpperCase(),
                  accent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              log.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                sBadge(
                  'To: ${log.sendTo[0].toUpperCase()}${log.sendTo.substring(1)}',
                  _kPri,
                ),
                const SizedBox(width: 8),
                if (log.targetData.isNotEmpty)
                  Expanded(
                    child: Text(
                      _targetSummary(log),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
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
    return dt != null ? DateFormat('dd MMM yyyy, HH:mm').format(dt) : d;
  }

  String _targetSummary(EmailSmsLog log) {
    final td = log.targetData;
    if (td.containsKey('role_id')) return 'Role #${td['role_id']}';
    if (td.containsKey('user_ids')) {
      final ids = td['user_ids'];
      if (ids is List) return '${ids.length} user(s)';
    }
    if (td.containsKey('class_id')) {
      return 'Class #${td['class_id']}${td.containsKey('section_id') ? ' / Section #${td['section_id']}' : ''}';
    }
    return '';
  }
}
