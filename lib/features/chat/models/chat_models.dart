/// Chat module data models — mirrors Django backend models.

class ChatUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? userType; // 'student' | 'staff'

  const ChatUser({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.userType,
  });

  String get fullName {
    final n = '$firstName $lastName'.trim();
    return n.isNotEmpty ? n : username;
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  factory ChatUser.fromJson(Map<String, dynamic> j) {
    // ID can be int or string from different endpoints
    final rawId = j['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return ChatUser(
      id: id,
      username: j['username'] as String? ?? '',
      firstName: j['first_name'] as String? ?? '',
      lastName: j['last_name'] as String? ?? '',
      email: j['email'] as String? ?? '',
      userType: j['user_type'] as String?,
    );
  }
}

// ── Message Types ────────────────────────────────────────────────────────────
enum MessageType { text, image, pdf, doc, voice }

MessageType _msgType(dynamic v) {
  switch (v) {
    case 1:
      return MessageType.image;
    case 2:
      return MessageType.pdf;
    case 3:
      return MessageType.doc;
    case 4:
      return MessageType.voice;
    default:
      return MessageType.text;
  }
}

int _msgTypeInt(MessageType t) {
  switch (t) {
    case MessageType.image:
      return 1;
    case MessageType.pdf:
      return 2;
    case MessageType.doc:
      return 3;
    case MessageType.voice:
      return 4;
    case MessageType.text:
      return 0;
  }
}

// ── Conversation (1-to-1 message) ────────────────────────────────────────────
class Conversation {
  final int id;
  final ChatUser fromUser;
  final ChatUser toUser;
  final String message;
  final MessageType messageType;
  final int status; // 0=UNREAD, 1=READ
  final String? fileName;
  final String? originalFileName;
  final Conversation? reply;
  final Conversation? forward;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.fromUser,
    required this.toUser,
    this.message = '',
    this.messageType = MessageType.text,
    this.status = 0,
    this.fileName,
    this.originalFileName,
    this.reply,
    this.forward,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRead => status == 1;

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: j['id'] as int,
        fromUser: ChatUser.fromJson(j['from_user'] as Map<String, dynamic>),
        toUser: ChatUser.fromJson(j['to_user'] as Map<String, dynamic>),
        message: j['message'] as String? ?? '',
        messageType: _msgType(j['message_type']),
        status: j['status'] as int? ?? 0,
        fileName: j['file_name'] as String?,
        originalFileName: j['original_file_name'] as String?,
        reply: j['reply'] != null
            ? Conversation.fromJson(j['reply'] as Map<String, dynamic>)
            : null,
        forward: j['forward'] != null
            ? Conversation.fromJson(j['forward'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}

// ── Group ────────────────────────────────────────────────────────────────────
class ChatGroup {
  final String id; // UUID
  final String name;
  final String description;
  final String? photoUrl;
  final int privacy; // 1=PUBLIC, 2=PRIVATE
  final int groupType; // 1=OPEN, 2=CLOSED
  final bool readOnly;
  final ChatUser? createdBy;
  final int memberCount;
  final List<GroupMember> members;
  final DateTime createdAt;

  const ChatGroup({
    required this.id,
    required this.name,
    this.description = '',
    this.photoUrl,
    this.privacy = 2,
    this.groupType = 1,
    this.readOnly = false,
    this.createdBy,
    this.memberCount = 0,
    this.members = const [],
    required this.createdAt,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> j) {
    // Backend may send created_by_detail or created_by
    final creatorMap = j['created_by_detail'] ?? j['created_by'];
    // ID can be UUID string or int
    final rawId = j['id'];
    final id = rawId is String ? rawId : rawId?.toString() ?? '';

    return ChatGroup(
        id: id,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        photoUrl: j['photo_url'] as String?,
        privacy: j['privacy'] as int? ?? 2,
        groupType: j['group_type'] as int? ?? 1,
        readOnly: j['read_only'] as bool? ?? false,
        createdBy: creatorMap is Map<String, dynamic>
            ? ChatUser.fromJson(creatorMap)
            : null,
        memberCount: j['member_count'] as int? ?? j['user_count'] as int? ?? 0,
        members: (j['members'] as List<dynamic>?)
                ?.map((m) =>
                    GroupMember.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(
            j['created_at'] as String? ?? DateTime.now().toIso8601String()),
      );
  }
}

// ── Group Member ─────────────────────────────────────────────────────────────
class GroupMember {
  final int id;
  final ChatUser user;
  final int role; // 1=ADMIN, 2=MODERATOR, 3=MEMBER

  const GroupMember({required this.id, required this.user, this.role = 3});

  String get roleLabel {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Moderator';
      default:
        return 'Member';
    }
  }

  factory GroupMember.fromJson(Map<String, dynamic> j) => GroupMember(
        id: j['id'] as int? ?? 0,
        user: ChatUser.fromJson(j['user'] as Map<String, dynamic>),
        role: j['role'] as int? ?? 3,
      );
}

// ── Group Message ────────────────────────────────────────────────────────────
class GroupMessage {
  final int id;
  final ChatUser sender;
  final String groupId;
  final String message;
  final MessageType messageType;
  final String? fileName;
  final String? originalFileName;
  final DateTime createdAt;

  const GroupMessage({
    required this.id,
    required this.sender,
    required this.groupId,
    this.message = '',
    this.messageType = MessageType.text,
    this.fileName,
    this.originalFileName,
    required this.createdAt,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> j) => GroupMessage(
        id: j['id'] as int,
        sender: ChatUser.fromJson(j['sender'] as Map<String, dynamic>? ??
            j['from_user'] as Map<String, dynamic>? ??
            {'id': 0, 'username': ''}),
        groupId: j['group'] as String? ?? '',
        message: j['message'] as String? ?? '',
        messageType: _msgType(j['message_type']),
        fileName: j['file_name'] as String?,
        originalFileName: j['original_file_name'] as String?,
        createdAt: DateTime.parse(
            j['created_at'] as String? ?? DateTime.now().toIso8601String()),
      );
}

// ── Invitation ───────────────────────────────────────────────────────────────
class Invitation {
  final int id;
  final ChatUser fromUser;
  final ChatUser toUser;
  final int status; // 0=PENDING, 1=CONNECTED, 2=BLOCKED
  final DateTime createdAt;

  const Invitation({
    required this.id,
    required this.fromUser,
    required this.toUser,
    this.status = 0,
    required this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case 1:
        return 'Connected';
      case 2:
        return 'Blocked';
      default:
        return 'Pending';
    }
  }

  factory Invitation.fromJson(Map<String, dynamic> j) => Invitation(
        id: j['id'] as int,
        fromUser: ChatUser.fromJson(j['from_user'] as Map<String, dynamic>),
        toUser: ChatUser.fromJson(j['to_user'] as Map<String, dynamic>),
        status: j['status'] as int? ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

// ── Helper: wrap a user + their last message for sidebar display ─────────────
class ChatThread {
  final ChatUser user;
  Conversation? lastMessage;
  int unreadCount;

  ChatThread({
    required this.user,
    this.lastMessage,
    this.unreadCount = 0,
  });
}

// Export the int converter for the repo
int msgTypeToInt(MessageType t) => _msgTypeInt(t);
