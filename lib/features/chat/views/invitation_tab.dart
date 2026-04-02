import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_models.dart';
import '../../../core/widgets/school_loader.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// INVITATION TAB — search users, send / accept / decline invitations
// ═══════════════════════════════════════════════════════════════════════════════

const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

const _kAvatarPalette = [
  Color(0xFF6366F1),
  Color(0xFF7C3AED),
  Color(0xFF0EA5E9),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
];

Color _avatarColor(String name) =>
    _kAvatarPalette[name.isEmpty ? 0 : name.codeUnitAt(0) % 6];

class InvitationTab extends StatefulWidget {
  const InvitationTab({super.key});

  @override
  State<InvitationTab> createState() => _InvitationTabState();
}

class _InvitationTabState extends State<InvitationTab> {
  final _searchCtrl = TextEditingController();

  ChatController get _c => Get.find<ChatController>();

  @override
  void initState() {
    super.initState();
    _c.loadInvitations();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filter types ──────────────────────────────────────────────────────────

  static const _filters = ['all', 'staff', 'student'];
  static const _filterLabels = ['All', 'Staff', 'Students'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_c.isLoadingInv.value && _c.pendingInvitations.isEmpty) {
        return const Center(child: SchoolLoader(message: 'Loading invitations...'));
      }
      return RefreshIndicator(
        color: _kPri,
        onRefresh: _c.loadInvitations,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildFilterRow(),
            const SizedBox(height: 14),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildSearchResults(),
            const SizedBox(height: 8),
            _buildPendingSection(),
          ],
        ),
      );
    });
  }

  // ── User-type filter pills ────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Obx(() {
      final active = _c.invUserType.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (i) {
            final isActive = active == _filters[i];
            return Padding(
              padding: EdgeInsets.only(right: i < _filters.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () {
                  _c.invUserType.value = _filters[i];
                  if (_searchCtrl.text.trim().isNotEmpty) {
                    _c.searchInvitationUsers();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(colors: [_kPri, _kVio])
                        : null,
                    color: isActive ? null : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: isActive
                        ? null
                        : Border.all(color: _kPri.withValues(alpha: 0.15)),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: _kPri.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    _filterLabels[i],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kPri.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          ShaderMask(
            shaderCallback: (r) =>
                const LinearGradient(colors: [_kPri, _kVio]).createShader(r),
            child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1F2937)),
              decoration: InputDecoration(
                hintText: 'Search users to invite...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) {
                _c.invSearchQuery.value = v;
              },
              onSubmitted: (_) => _c.searchInvitationUsers(),
            ),
          ),
          _GradientButton(
            label: 'Search',
            onTap: _c.searchInvitationUsers,
            colors: const [_kPri, _kVio],
            compact: true,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  // ── Search results ────────────────────────────────────────────────────────

  Widget _buildSearchResults() {
    return Obx(() {
      final results = _c.invSearchResults;
      if (results.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Search Results',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          ...results.map((user) => _buildUserCard(user)),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildUserCard(ChatUser user) {
    final accent = _avatarColor(user.fullName);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, accent.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
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
              ),
              alignment: Alignment.center,
              child: Text(
                user.initials,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  if (user.userType != null) ...[
                    const SizedBox(height: 3),
                    _TypeBadge(type: user.userType!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _GradientButton(
              label: 'Send Invitation',
              onTap: () => _c.sendInvitation(user.id),
              colors: const [_kPri, _kVio],
            ),
          ],
        ),
      ),
    );
  }

  // ── Pending invitations section ───────────────────────────────────────────

  Widget _buildPendingSection() {
    return Obx(() {
      final pending = _c.pendingInvitations;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              ShaderMask(
                shaderCallback: (r) =>
                    const LinearGradient(colors: [_kPri, _kVio]).createShader(r),
                child: const Icon(Icons.mail_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Pending Invitations',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kPri, _kVio]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pending.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (pending.isEmpty) _buildEmptyPending(),
          ...pending.map((inv) => _buildInvitationCard(inv)),
        ],
      );
    });
  }

  Widget _buildEmptyPending() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _kPri.withValues(alpha: 0.10),
                    _kVio.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: Icon(
                Icons.mark_email_read_rounded,
                size: 36,
                color: _kPri.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No pending invitations',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Search for users above to send new chat invitations.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard(Invitation inv) {
    // Determine direction — we show from → to
    final isSent = true; // from the perspective of fromUser
    // We don't have a currentUserId helper; show both users with a direction
    // badge. The backend returns invitations relevant to the logged-in user,
    // so fromUser == current user means "Sent", else "Received".
    // Since we cannot determine this without a currentUser helper, we show
    // fromUser → toUser and label via UI context.
    // As a heuristic: if the logged-in user is among connectedUsers we could
    // check, but the simplest approach is to expose both names.

    final accent = _avatarColor(inv.fromUser.fullName);
    final dateStr = _formatDate(inv.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, accent.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: direction badge + date
            Row(
              children: [
                _DirectionBadge(fromName: inv.fromUser.fullName, toName: inv.toUser.fullName),
                const Spacer(),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // User info row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    inv.fromUser.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${inv.fromUser.fullName}  \u2192  ${inv.toUser.fullName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        inv.statusLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Action buttons
            _buildInvitationActions(inv),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationActions(Invitation inv) {
    // Show Accept/Decline for all pending invitations (the backend will
    // enforce permissions — only the recipient can accept).
    // We also show a "Waiting response" hint.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _GradientButton(
          label: 'Accept',
          onTap: () => _c.acceptInvitation(inv.id),
          colors: const [Color(0xFF10B981), Color(0xFF059669)],
        ),
        _GradientButton(
          label: 'Decline',
          onTap: () => _c.declineInvitation(inv.id),
          colors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'or waiting for response...',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF9CA3AF),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Small gradient action button used throughout the tab.
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final List<Color> colors;
  final bool compact;

  const _GradientButton({
    required this.label,
    required this.onTap,
    required this.colors,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 8 : 9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: compact ? 12 : 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// User type badge (Staff / Student).
class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isStaff = type.toLowerCase() == 'staff';
    final bg = isStaff
        ? const Color(0xFF6366F1).withValues(alpha: 0.10)
        : const Color(0xFF10B981).withValues(alpha: 0.10);
    final fg = isStaff ? const Color(0xFF6366F1) : const Color(0xFF059669);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type[0].toUpperCase() + type.substring(1),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

/// From → To direction badge.
class _DirectionBadge extends StatelessWidget {
  final String fromName;
  final String toName;
  const _DirectionBadge({required this.fromName, required this.toName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _kPri.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.send_rounded, size: 12, color: _kPri),
              const SizedBox(width: 4),
              Text(
                'Invitation',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _kPri,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
