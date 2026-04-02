// ── Communication Models ────────────────────────────────────────────────────

class NoticeBoard {
  final int id;
  final String title;
  final String message;
  final List<int> informTo;
  final List<String> informToLabels;
  final String? noticeDate;
  final String? publishDate;
  final bool isPublished;
  final String? createdAt;

  const NoticeBoard({
    required this.id,
    required this.title,
    required this.message,
    required this.informTo,
    required this.informToLabels,
    this.noticeDate,
    this.publishDate,
    this.isPublished = false,
    this.createdAt,
  });

  factory NoticeBoard.fromJson(Map<String, dynamic> j) => NoticeBoard(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        message: j['message']?.toString() ?? '',
        informTo: _intList(j['inform_to']),
        informToLabels: _strList(j['inform_to_labels'] ?? j['inform_to_display']),
        noticeDate: j['notice_date']?.toString(),
        publishDate: j['publish_date']?.toString(),
        isPublished: j['is_published'] == true,
        createdAt: j['created_at']?.toString(),
      );

  static List<int> _intList(dynamic v) {
    if (v is List) return v.map((e) => (e as num).toInt()).toList();
    return [];
  }

  static List<String> _strList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}

class EmailSmsLog {
  final int id;
  final String title;
  final String description;
  final String sendThrough;
  final String sendTo;
  final Map<String, dynamic> targetData;
  final String? createdAt;

  const EmailSmsLog({
    required this.id,
    required this.title,
    required this.description,
    required this.sendThrough,
    required this.sendTo,
    required this.targetData,
    this.createdAt,
  });

  factory EmailSmsLog.fromJson(Map<String, dynamic> j) => EmailSmsLog(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        sendThrough: j['send_through']?.toString() ?? 'email',
        sendTo: j['send_to']?.toString() ?? 'group',
        targetData: j['target_data'] is Map<String, dynamic>
            ? j['target_data'] as Map<String, dynamic>
            : {},
        createdAt: j['created_at']?.toString(),
      );
}

class HolidayCalendar {
  final int id;
  final String title;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final String? createdAt;

  const HolidayCalendar({
    required this.id,
    required this.title,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.createdAt,
  });

  factory HolidayCalendar.fromJson(Map<String, dynamic> j) => HolidayCalendar(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        startDate: j['start_date']?.toString(),
        endDate: j['end_date']?.toString(),
        isActive: j['is_active'] != false,
        createdAt: j['created_at']?.toString(),
      );
}

// ── Support refs ────────────────────────────────────────────────────────────

class CommRole {
  final int id;
  final String name;
  const CommRole({required this.id, required this.name});
  factory CommRole.fromJson(Map<String, dynamic> j) => CommRole(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? j['role_name']?.toString() ?? '',
      );
}

class CommUser {
  final int id;
  final String name;
  final String? email;
  const CommUser({required this.id, required this.name, this.email});
  factory CommUser.fromJson(Map<String, dynamic> j) => CommUser(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['full_name']?.toString() ??
            j['name']?.toString() ??
            '${j['first_name'] ?? ''} ${j['last_name'] ?? ''}'.trim(),
        email: j['email']?.toString(),
      );
}

class CommClassRef {
  final int id;
  final String name;
  const CommClassRef({required this.id, required this.name});
  factory CommClassRef.fromJson(Map<String, dynamic> j) => CommClassRef(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '',
      );
}

class CommSectionRef {
  final int id;
  final String name;
  final int classId;
  const CommSectionRef({required this.id, required this.name, required this.classId});
  factory CommSectionRef.fromJson(Map<String, dynamic> j) => CommSectionRef(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '',
        classId: (j['class_id'] as num?)?.toInt() ??
            (j['school_class'] as num?)?.toInt() ??
            (j['school_class_id'] as num?)?.toInt() ??
            0,
      );
}
