import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_models.dart';
import '../repositories/chat_repository.dart';

// ── Theme constants ─────────────────────────────────────────────────────────
const _kPri = Color(0xFF6366F1);
const _kVio = Color(0xFF7C3AED);

const _kAvatarPalette = [
  Color(0xFF6366F1),
  Color(0xFF7C3AED),
  Color(0xFF06B6D4),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFF10B981),
];

Color _accentFor(String name) =>
    _kAvatarPalette[name.isEmpty ? 0 : name.codeUnitAt(0) % 6];

// ── Chat Window ─────────────────────────────────────────────────────────────

class ChatWindow extends StatelessWidget {
  const ChatWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Obx(() {
      final user = ctrl.selectedUser.value;
      final group = ctrl.selectedGroup.value;
      final hasSelection = user != null || group != null;

      if (!hasSelection) return _buildEmptyState(context);

      final isGroup = group != null;
      final title = isGroup ? group.name : user!.fullName;
      final subtitle = isGroup
          ? '${group.memberCount} members'
          : (user!.userType ?? 'User');

      return Column(
        children: [
          // ── Header bar ──────────────────────────────────────────────
          _ChatHeader(
            title: title,
            subtitle: subtitle,
            isGroup: isGroup,
            showBack: isNarrow,
            onBack: ctrl.clearSelection,
          ),
          // ── Message list ────────────────────────────────────────────
          Expanded(
            child: ctrl.isLoadingMessages.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: _kPri.withValues(alpha: 0.6),
                      strokeWidth: 2.5,
                    ),
                  )
                : isGroup
                    ? _GroupMessageList(messages: ctrl.currentGroupMessages)
                    : _DirectMessageList(
                        messages: ctrl.currentMessages,
                        selectedUserId: user!.id,
                      ),
          ),
          // ── Input bar ──────────────────────────────────────────────
          _MessageInputBar(isGroup: isGroup),
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _kPri.withValues(alpha: 0.15),
                  _kVio.withValues(alpha: 0.10),
                ],
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 38,
              color: _kPri.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Start a conversation',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select a chat or search for someone',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isGroup;
  final bool showBack;
  final VoidCallback onBack;

  const _ChatHeader({
    required this.title,
    required this.subtitle,
    required this.isGroup,
    required this.showBack,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(title);

    return Container(
      padding: EdgeInsets.only(
        left: showBack ? 4 : 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
          if (showBack)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withValues(alpha: 0.9),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent, accent.withValues(alpha: 0.7)],
              ),
            ),
            child: Center(
              child: isGroup
                  ? const Icon(Icons.group_rounded, size: 20, color: Colors.white)
                  : Text(
                      title.isNotEmpty ? title[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    if (!isGroup) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_rounded,
                size: 20, color: Colors.grey.shade600),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ── Direct Message List ─────────────────────────────────────────────────────

class _DirectMessageList extends StatelessWidget {
  final List<Conversation> messages;
  final int selectedUserId;

  const _DirectMessageList({
    required this.messages,
    required this.selectedUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: _emptyMessages(),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[messages.length - 1 - i];
        final isSent = msg.fromUser.id != selectedUserId;

        return _MessageBubble(
          text: msg.message,
          isSent: isSent,
          time: msg.createdAt,
          isRead: msg.isRead,
          messageType: msg.messageType,
          fileName: msg.originalFileName ?? msg.fileName,
          replyText: msg.reply?.message,
          replySender: msg.reply?.fromUser.fullName,
          isGroup: false,
        );
      },
    );
  }
}

// ── Group Message List ──────────────────────────────────────────────────────

class _GroupMessageList extends StatelessWidget {
  final List<GroupMessage> messages;

  const _GroupMessageList({required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(child: _emptyMessages());
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[messages.length - 1 - i];

        return _MessageBubble(
          text: msg.message,
          isSent: false, // Group msgs — show all as received style for now
          time: msg.createdAt,
          isRead: false,
          messageType: msg.messageType,
          fileName: msg.originalFileName ?? msg.fileName,
          isGroup: true,
          senderName: msg.sender.fullName,
        );
      },
    );
  }
}

// ── Message Bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isSent;
  final DateTime time;
  final bool isRead;
  final MessageType messageType;
  final String? fileName;
  final String? replyText;
  final String? replySender;
  final bool isGroup;
  final String? senderName;

  const _MessageBubble({
    required this.text,
    required this.isSent,
    required this.time,
    required this.isRead,
    required this.messageType,
    this.fileName,
    this.replyText,
    this.replySender,
    required this.isGroup,
    this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final maxBubbleW = screenW * 0.72;

    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxBubbleW),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment:
              isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender name for group messages
            if (isGroup && senderName != null && senderName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 3),
                child: Text(
                  senderName!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _accentFor(senderName!),
                  ),
                ),
              ),
            // Bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSent
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_kPri, _kVio],
                      )
                    : null,
                color: isSent ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      isSent ? const Radius.circular(18) : Radius.zero,
                  bottomRight:
                      isSent ? Radius.zero : const Radius.circular(18),
                ),
                boxShadow: isSent
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply preview
                  if (replyText != null && replyText!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSent
                            ? Colors.white.withValues(alpha: 0.15)
                            : _kPri.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: isSent
                                ? Colors.white.withValues(alpha: 0.5)
                                : _kPri.withValues(alpha: 0.4),
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (replySender != null)
                            Text(
                              replySender!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSent
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : _kPri,
                              ),
                            ),
                          Text(
                            replyText!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isSent
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  // File attachment
                  if (messageType != MessageType.text && fileName != null)
                    _FileAttachment(
                      type: messageType,
                      fileName: fileName!,
                      isSent: isSent,
                    ),
                  // Message text
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.4,
                        color: isSent ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Time + read status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(time),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isSent
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.grey.shade400,
                        ),
                      ),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 14,
                          color: isRead
                              ? const Color(0xFF38BDF8)
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ── File Attachment ─────────────────────────────────────────────────────────

class _FileAttachment extends StatelessWidget {
  final MessageType type;
  final String fileName;
  final bool isSent;

  const _FileAttachment({
    required this.type,
    required this.fileName,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (type) {
      case MessageType.image:
        icon = Icons.image_rounded;
        iconColor = const Color(0xFF06B6D4);
        break;
      case MessageType.pdf:
        icon = Icons.picture_as_pdf_rounded;
        iconColor = const Color(0xFFEF4444);
        break;
      case MessageType.doc:
        icon = Icons.description_rounded;
        iconColor = const Color(0xFF3B82F6);
        break;
      case MessageType.voice:
        icon = Icons.mic_rounded;
        iconColor = const Color(0xFF10B981);
        break;
      default:
        icon = Icons.attach_file_rounded;
        iconColor = Colors.grey;
    }

    if (isSent) iconColor = Colors.white.withValues(alpha: 0.85);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSent
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              fileName,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSent ? Colors.white : Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Input Bar ───────────────────────────────────────────────────────

class _MessageInputBar extends StatefulWidget {
  final bool isGroup;
  const _MessageInputBar({required this.isGroup});
  @override
  State<_MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<_MessageInputBar> {
  bool _showEmoji = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  static const _emojis = [
    '😀', '😂', '🥰', '😍', '🤗', '😊', '😉', '👍', '👋', '🙏',
    '❤️', '🔥', '🎉', '⭐', '👏', '💯', '✅', '📚', '🏫', '✏️',
    '🎓', '📝', '📖', '🧑‍🏫', '🧑‍🎓', '🤔', '😅', '🙌', '👀', '💪',
    '🌟', '🎈', '📌', '🔔', '💬', '😎', '🤝', '🥳', '😇', '💡',
  ];

  void _toggleEmoji() => setState(() => _showEmoji = !_showEmoji);

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordSeconds++);
    });
    // NOTE: actual audio recording needs platform setup for record package
    // This UI shows the recording state; wire to Record() when permissions are configured
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    setState(() => _isRecording = false);
    Get.snackbar('Voice', 'Voice recording (${_recordSeconds}s) — requires microphone permission setup');
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatController>();
    final bottom = MediaQuery.of(context).padding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply preview
        Obx(() {
          final reply = ctrl.replyingTo.value;
          if (reply == null) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _kPri.withValues(alpha: 0.08),
                _kVio.withValues(alpha: 0.04),
              ]),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: _kPri, width: 3)),
            ),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Replying to ${reply.fromUser.fullName}',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _kPri)),
                  const SizedBox(height: 2),
                  Text(reply.message, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              )),
              GestureDetector(
                onTap: ctrl.cancelReply,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _kPri.withValues(alpha: 0.1)),
                  child: Icon(Icons.close_rounded, size: 14, color: _kPri),
                ),
              ),
            ]),
          );
        }),

        // Input bar
        Container(
          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: bottom + 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFF5F3FF)],
            ),
            boxShadow: [BoxShadow(color: _kPri.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3))],
          ),
          child: _isRecording ? _buildRecordingBar() : _buildTextBar(ctrl),
        ),

        // Emoji panel
        if (_showEmoji) _buildEmojiPanel(ctrl),
      ],
    );
  }

  Widget _buildTextBar(ChatController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kPri.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: _kPri.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Emoji toggle
        IconButton(
          onPressed: _toggleEmoji,
          icon: Icon(
            _showEmoji ? Icons.keyboard_rounded : Icons.emoji_emotions_rounded,
            size: 22, color: _showEmoji ? _kPri : const Color(0xFF9CA3AF),
          ),
          splashRadius: 18,
        ),
        // Text field
        Expanded(
          child: TextField(
            controller: ctrl.messageCtrl,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF111827)),
            maxLines: 4,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            onTap: () { if (_showEmoji) setState(() => _showEmoji = false); },
            decoration: InputDecoration(
              hintText: 'Type a message...',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        // Attach button
        SizedBox(
          width: 36, height: 36,
          child: IconButton(
            onPressed: () => _showAttachOptions(context),
            icon: const Icon(Icons.attach_file_rounded, size: 20, color: Color(0xFF9CA3AF)),
            padding: EdgeInsets.zero,
          ),
        ),
        // Voice record button
        GestureDetector(
          onTap: _startRecording,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            ),
            child: const Icon(Icons.mic_rounded, size: 18, color: Color(0xFFEF4444)),
          ),
        ),
        const SizedBox(width: 4),
        // Send button
        Obx(() => GestureDetector(
              onTap: ctrl.isSending.value ? null
                  : widget.isGroup ? ctrl.sendGroupMessage : ctrl.sendMessage,
              child: Container(
                width: 40, height: 40,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_kPri, _kVio]),
                  boxShadow: [BoxShadow(color: _kPri.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ctrl.isSending.value
                    ? const Padding(padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 20, color: Colors.white),
              ),
            )),
      ]),
    );
  }

  Widget _buildRecordingBar() {
    final mins = (_recordSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_recordSeconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFFEF4444).withValues(alpha: 0.08),
          const Color(0xFFEF4444).withValues(alpha: 0.04),
        ]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        // Pulsing red dot
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: const Color(0xFFEF4444),
            boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.4), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 10),
        Text('Recording $mins:$secs',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFEF4444))),
        const Spacer(),
        // Cancel
        GestureDetector(
          onTap: () { _recordTimer?.cancel(); setState(() => _isRecording = false); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF9CA3AF).withValues(alpha: 0.3)),
            ),
            child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
          ),
        ),
        const SizedBox(width: 8),
        // Stop & send
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
              boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withValues(alpha: 0.3), blurRadius: 8)],
            ),
            child: const Icon(Icons.stop_rounded, size: 20, color: Colors.white),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmojiPanel(ChatController ctrl) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kPri.withValues(alpha: 0.08))),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: _emojis.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            ctrl.messageCtrl.text += _emojis[i];
            ctrl.messageCtrl.selection = TextSelection.collapsed(
              offset: ctrl.messageCtrl.text.length,
            );
          },
          child: Center(
            child: Text(_emojis[i], style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }

  void _showAttachOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F3FF), Colors.white],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_kPri, _kVio]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachOption(icon: Icons.camera_alt_rounded, label: 'Camera',
                    color: const Color(0xFF6366F1), onTap: () => Navigator.pop(context)),
                _AttachOption(icon: Icons.insert_drive_file_rounded, label: 'Document',
                    color: const Color(0xFF7C3AED), onTap: () { Navigator.pop(context); _pickFile(); }),
                _AttachOption(icon: Icons.image_rounded, label: 'Gallery',
                    color: const Color(0xFF06B6D4), onTap: () { Navigator.pop(context); _pickImage(); }),
                _AttachOption(icon: Icons.mic_rounded, label: 'Voice',
                    color: const Color(0xFFEF4444), onTap: () { Navigator.pop(context); _startRecording(); }),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  void _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final ctrl = Get.find<ChatController>();
        final path = result.files.single.path!;
        final ext = path.split('.').last.toLowerCase();
        MessageType type = MessageType.doc;
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) type = MessageType.image;
        if (ext == 'pdf') type = MessageType.pdf;

        if (widget.isGroup && ctrl.selectedGroup.value != null) {
          await ChatRepository.instance.sendGroupFile(
            groupId: ctrl.selectedGroup.value!.id, filePath: path, type: type);
          ctrl.loadGroupMessages(ctrl.selectedGroup.value!.id);
        } else if (ctrl.selectedUser.value != null) {
          await ChatRepository.instance.sendFileMessage(
            toUserId: ctrl.selectedUser.value!.id, filePath: path, type: type);
          ctrl.loadConversation(ctrl.selectedUser.value!.id);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
    }
  }

  void _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        final ctrl = Get.find<ChatController>();
        final path = result.files.single.path!;
        if (widget.isGroup && ctrl.selectedGroup.value != null) {
          await ChatRepository.instance.sendGroupFile(
            groupId: ctrl.selectedGroup.value!.id, filePath: path, type: MessageType.image);
          ctrl.loadGroupMessages(ctrl.selectedGroup.value!.id);
        } else if (ctrl.selectedUser.value != null) {
          await ChatRepository.instance.sendFileMessage(
            toUserId: ctrl.selectedUser.value!.id, filePath: path, type: MessageType.image);
          ctrl.loadConversation(ctrl.selectedUser.value!.id);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }
}

// ── Attach Option ───────────────────────────────────────────────────────────

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.06)]),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280))),
      ]),
    );
  }
}

// ── Empty messages helper ───────────────────────────────────────────────────

Widget _emptyMessages() {
  return Column(
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
              _kPri.withValues(alpha: 0.12),
              _kVio.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Icon(
          Icons.chat_rounded,
          size: 30,
          color: _kPri.withValues(alpha: 0.4),
        ),
      ),
      const SizedBox(height: 14),
      Text(
        'Start a conversation',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
      ),
    ],
  );
}
