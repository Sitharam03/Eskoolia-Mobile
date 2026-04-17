import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// CHAT SIDEBAR — conversations list + groups list with tabbed navigation
// ═══════════════════════════════════════════════════════════════════════════════

const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

// Avatar color palette — 6 unique gradients keyed by name
const _avatarGradients = <List<Color>>[
  [Color(0xFF6366F1), Color(0xFF818CF8)], // indigo
  [Color(0xFF7C3AED), Color(0xFFA78BFA)], // violet
  [Color(0xFF2563EB), Color(0xFF60A5FA)], // blue
  [Color(0xFF059669), Color(0xFF34D399)], // emerald
  [Color(0xFFD97706), Color(0xFFFBBF24)], // amber
  [Color(0xFFDC2626), Color(0xFFF87171)], // rose
];

class ChatSidebar extends StatelessWidget {
  ChatSidebar({super.key});

  final ChatController _ctrl = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F3FF),
      child: Column(
        children: [
          // ── Tab bar ──
          _buildTabs(),
          // ── Search bar ──
          _buildSearchBar(),
          // ── List content ──
          Expanded(
            child: Obx(() {
              final tab = _ctrl.activeTab.value;
              if (tab == 0) return _buildDirectMessagesList();
              return _buildGroupsList();
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TABS — Direct Messages / Groups
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTabs() {
    return Obx(() {
      final active = _ctrl.activeTab.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kPri.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Expanded(child: _tabButton('Direct Messages', 0, active)),
              Expanded(child: _tabButton('Groups', 1, active)),
            ],
          ),
        ),
      );
    });
  }

  Widget _tabButton(String label, int index, int active) {
    final isActive = index == active;
    return GestureDetector(
      onTap: () => _ctrl.activeTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kPri, _kVio],
                )
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _kPri.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEARCH BAR — frosted glass style
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kPri.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: _kPri.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => _ctrl.searchQuery.value = v,
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E1B4B)),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [_kPri, _kVio],
              ).createShader(rect),
              child: const Icon(Icons.search_rounded, size: 20, color: Colors.white),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DIRECT MESSAGES LIST
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDirectMessagesList() {
    return Obx(() {
      if (_ctrl.isLoadingUsers.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final threads = _ctrl.filteredRecentChats;
      if (threads.isEmpty) {
        return _buildEmptyDm();
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: threads.length,
        itemBuilder: (_, i) => _ConversationTile(
          thread: threads[i],
          isSelected: _ctrl.selectedUser.value?.id == threads[i].user.id,
          onTap: () => _ctrl.selectUser(threads[i].user),
        ),
      );
    });
  }

  Widget _buildEmptyDm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
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
                Icons.chat_bubble_outline_rounded,
                size: 32,
                color: _kPri.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start a new chat by tapping the compose button',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GROUPS LIST
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildGroupsList() {
    return Obx(() {
      final groups = _ctrl.filteredGroups;
      if (groups.isEmpty) {
        return _buildEmptyGroups();
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: groups.length,
        itemBuilder: (_, i) => _GroupTile(
          group: groups[i],
          isSelected: _ctrl.selectedGroup.value?.id == groups[i].id,
          onTap: () => _ctrl.selectGroup(groups[i]),
        ),
      );
    });
  }

  Widget _buildEmptyGroups() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
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
                Icons.groups_rounded,
                size: 32,
                color: _kPri.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No groups yet',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Join or create a group to start collaborating with your class',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONVERSATION TILE — single DM item in the sidebar
// ═══════════════════════════════════════════════════════════════════════════════

class _ConversationTile extends StatelessWidget {
  final ChatThread thread;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.thread,
    required this.isSelected,
    required this.onTap,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final user = thread.user;
    final lastMsg = thread.lastMessage;
    final unread = thread.unreadCount;
    final gradIdx = user.fullName.isNotEmpty
        ? user.fullName.codeUnitAt(0) % 6
        : 0;
    final avatarColors = _avatarGradients[gradIdx];

    // Last message preview text
    String subtitle;
    if (lastMsg != null) {
      if (lastMsg.message.isNotEmpty) {
        subtitle = lastMsg.message;
      } else if (lastMsg.messageType == MessageType.image) {
        subtitle = '📷 Image';
      } else if (lastMsg.messageType == MessageType.pdf) {
        subtitle = '📄 PDF';
      } else if (lastMsg.messageType == MessageType.doc) {
        subtitle = '📎 Document';
      } else if (lastMsg.messageType == MessageType.voice) {
        subtitle = '🎤 Voice message';
      } else {
        subtitle = 'Sent a message';
      }
    } else {
      subtitle = 'No messages yet';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _kPri.withValues(alpha: 0.10),
                        _kVio.withValues(alpha: 0.06),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.6),
              border: Border.all(
                color: isSelected
                    ? _kPri.withValues(alpha: 0.20)
                    : Colors.transparent,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _kPri.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // ── Avatar ──
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: avatarColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avatarColors[0].withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                // ── Name + last message ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                              color: const Color(0xFF1E1B4B),
                            ),
                          ),
                        ),
                        if (lastMsg != null)
                          Text(
                            _timeAgo(lastMsg.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: unread > 0
                                  ? _kPri
                                  : const Color(0xFF9CA3AF),
                              fontWeight: unread > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: unread > 0
                                  ? const Color(0xFF374151)
                                  : const Color(0xFF9CA3AF),
                              fontWeight: unread > 0
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_kPri, _kVio]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unread',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GROUP TILE — single group item in the sidebar
// ═══════════════════════════════════════════════════════════════════════════════

class _GroupTile extends StatelessWidget {
  final ChatGroup group;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupTile({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradIdx = group.name.isNotEmpty
        ? group.name.codeUnitAt(0) % 6
        : 0;
    final avatarColors = _avatarGradients[gradIdx];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _kPri.withValues(alpha: 0.10),
                        _kVio.withValues(alpha: 0.06),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.6),
              border: Border.all(
                color: isSelected
                    ? _kPri.withValues(alpha: 0.20)
                    : Colors.transparent,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _kPri.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // ── Group icon avatar ──
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: avatarColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: avatarColors[0].withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // ── Name + member count ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 13,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.memberCount} member${group.memberCount != 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // ── Last activity ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _relativeTime(group.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: const Color(0xFFADB5BD),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Privacy badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: group.privacy == 1
                            ? const Color(0xFF22C55E).withValues(alpha: 0.10)
                            : _kPri.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        group.privacy == 1 ? 'Public' : 'Private',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: group.privacy == 1
                              ? const Color(0xFF16A34A)
                              : _kPri,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
  return '${(diff.inDays / 365).floor()}y';
}

