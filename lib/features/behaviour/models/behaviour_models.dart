// ── Behaviour Models ───────────────────────────────────────────────────────────

// ── Support refs ──────────────────────────────────────────────────────────────

class BAcademicYearRef {
  final int id;
  final String title;
  const BAcademicYearRef({required this.id, required this.title});
  factory BAcademicYearRef.fromJson(Map<String, dynamic> j) => BAcademicYearRef(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? j['name']?.toString() ?? '',
      );
}

class BClassRef {
  final int id;
  final String name;
  const BClassRef({required this.id, required this.name});
  factory BClassRef.fromJson(Map<String, dynamic> j) => BClassRef(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '',
      );
}

class BSectionRef {
  final int id;
  final String name;
  final int classId;
  const BSectionRef({required this.id, required this.name, required this.classId});
  factory BSectionRef.fromJson(Map<String, dynamic> j) => BSectionRef(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '',
        classId: (j['school_class'] as num?)?.toInt() ?? 0,
      );
}

class BStudentRef {
  final int id;
  final String name;
  final String admissionNo;
  final int? currentClassId;
  final int? currentSectionId;

  const BStudentRef({
    required this.id,
    required this.name,
    required this.admissionNo,
    this.currentClassId,
    this.currentSectionId,
  });

  factory BStudentRef.fromJson(Map<String, dynamic> j) {
    int? _n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is Map) return (v['id'] as num?)?.toInt();
      return int.tryParse(v.toString());
    }

    return BStudentRef(
      id: (j['id'] as num?)?.toInt() ?? 0,
      name:
          '${j['first_name']?.toString() ?? ''} ${j['last_name']?.toString() ?? ''}'
              .trim(),
      admissionNo: j['admission_no']?.toString() ?? '',
      currentClassId: _n(j['current_class']),
      currentSectionId: _n(j['current_section']),
    );
  }
}

// ── Incident ──────────────────────────────────────────────────────────────────

class Incident {
  final int id;
  final String title;
  final int point;
  final String description;
  final String createdAt;

  const Incident({
    required this.id,
    required this.title,
    required this.point,
    required this.description,
    required this.createdAt,
  });

  factory Incident.fromJson(Map<String, dynamic> j) => Incident(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        point: (j['point'] as num?)?.toInt() ?? 0,
        description: j['description']?.toString() ?? '',
        createdAt: j['created_at']?.toString() ?? '',
      );
}

// ── AssignedIncidentComment ───────────────────────────────────────────────────

class AssignedIncidentComment {
  final int id;
  final int assignedIncident;
  final int? user;
  final String userName;
  final String comment;
  final String createdAt;

  const AssignedIncidentComment({
    required this.id,
    required this.assignedIncident,
    this.user,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory AssignedIncidentComment.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) {
      if (v is num) return v.toInt();
      if (v is Map) return (v['id'] as num?)?.toInt() ?? 0;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return AssignedIncidentComment(
      id: _id(j['id']),
      assignedIncident: _id(j['assigned_incident']),
      user: j['user'] == null ? null : _id(j['user']),
      userName: j['user_name']?.toString() ?? '',
      comment: j['comment']?.toString() ?? '',
      createdAt: j['created_at']?.toString() ?? '',
    );
  }
}

// ── AssignedIncident ──────────────────────────────────────────────────────────

class AssignedIncident {
  final int id;
  final int? academicYear;
  final int incident;
  final String incidentTitle;
  final int student;
  final String studentName;
  final int? record;
  final int? classId;
  final int? sectionId;
  final int point;
  final int? assignedBy;
  final List<AssignedIncidentComment> comments;
  final String createdAt;

  const AssignedIncident({
    required this.id,
    this.academicYear,
    required this.incident,
    required this.incidentTitle,
    required this.student,
    required this.studentName,
    this.record,
    this.classId,
    this.sectionId,
    required this.point,
    this.assignedBy,
    required this.comments,
    required this.createdAt,
  });

  factory AssignedIncident.fromJson(Map<String, dynamic> j) {
    int _id(dynamic v) {
      if (v is num) return v.toInt();
      if (v is Map) return (v['id'] as num?)?.toInt() ?? 0;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    int? _nullId(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is Map) return (v['id'] as num?)?.toInt();
      return int.tryParse(v.toString());
    }

    final rawComments = j['comments'];
    final comments = <AssignedIncidentComment>[];
    if (rawComments is List) {
      for (final c in rawComments) {
        if (c is Map<String, dynamic>) {
          comments.add(AssignedIncidentComment.fromJson(c));
        }
      }
    }

    return AssignedIncident(
      id: _id(j['id']),
      academicYear: _nullId(j['academic_year']),
      incident: _id(j['incident']),
      incidentTitle: j['incident_title']?.toString() ?? '',
      student: _id(j['student']),
      studentName: j['student_name']?.toString() ?? '',
      record: _nullId(j['record']),
      classId: _nullId(j['class_id']),
      sectionId: _nullId(j['section_id']),
      point: (j['point'] as num?)?.toInt() ?? 0,
      assignedBy: _nullId(j['assigned_by']),
      comments: comments,
      createdAt: j['created_at']?.toString() ?? '',
    );
  }
}

// ── BehaviourSetting ──────────────────────────────────────────────────────────

class BehaviourSetting {
  final int id;
  final bool studentComment;
  final bool parentComment;
  final bool studentView;
  final bool parentView;

  const BehaviourSetting({
    required this.id,
    required this.studentComment,
    required this.parentComment,
    required this.studentView,
    required this.parentView,
  });

  static const empty = BehaviourSetting(
    id: 0,
    studentComment: false,
    parentComment: false,
    studentView: false,
    parentView: false,
  );

  factory BehaviourSetting.fromJson(Map<String, dynamic> j) => BehaviourSetting(
        id: (j['id'] as num?)?.toInt() ?? 0,
        studentComment: j['student_comment'] == true,
        parentComment: j['parent_comment'] == true,
        studentView: j['student_view'] == true,
        parentView: j['parent_view'] == true,
      );
}

// ── Report models ─────────────────────────────────────────────────────────────

// Student Incident Report (grouped per student with incident breakdown)
class StudentIncidentReportItem {
  final int id;
  final String incident;
  final int point;
  final String createdAt;

  const StudentIncidentReportItem({
    required this.id,
    required this.incident,
    required this.point,
    required this.createdAt,
  });

  factory StudentIncidentReportItem.fromJson(Map<String, dynamic> j) =>
      StudentIncidentReportItem(
        id: (j['id'] as num?)?.toInt() ?? 0,
        incident: j['incident']?.toString() ?? '',
        point: (j['point'] as num?)?.toInt() ?? 0,
        createdAt: j['created_at']?.toString() ?? '',
      );
}

class StudentIncidentReportRow {
  final int studentId;
  final String studentName;
  final String admissionNo;
  final int? classId;
  final int? sectionId;
  final int totalPoints;
  final int totalIncidents;
  final List<StudentIncidentReportItem> incidents;

  const StudentIncidentReportRow({
    required this.studentId,
    required this.studentName,
    required this.admissionNo,
    this.classId,
    this.sectionId,
    required this.totalPoints,
    required this.totalIncidents,
    required this.incidents,
  });

  factory StudentIncidentReportRow.fromJson(Map<String, dynamic> j) {
    int? _n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    final rawIncidents = j['incidents'];
    final incidents = <StudentIncidentReportItem>[];
    if (rawIncidents is List) {
      for (final i in rawIncidents) {
        if (i is Map<String, dynamic>) {
          incidents.add(StudentIncidentReportItem.fromJson(i));
        }
      }
    }

    return StudentIncidentReportRow(
      studentId: (j['student_id'] as num?)?.toInt() ?? 0,
      studentName: j['student_name']?.toString() ?? '',
      admissionNo: j['admission_no']?.toString() ?? '',
      classId: _n(j['class_id']),
      sectionId: _n(j['section_id']),
      totalPoints: (j['total_points'] as num?)?.toInt() ?? 0,
      totalIncidents: (j['total_incidents'] as num?)?.toInt() ?? 0,
      incidents: incidents,
    );
  }
}


class StudentSummaryRow {
  final int id;
  final String admissionNo;
  final String rollNo;
  final String firstName;
  final String lastName;
  final int? currentClass;
  final int? currentSection;
  final int totalIncidents;
  final int totalPoints;

  String get fullName => '$firstName $lastName'.trim();

  const StudentSummaryRow({
    required this.id,
    required this.admissionNo,
    required this.rollNo,
    required this.firstName,
    required this.lastName,
    this.currentClass,
    this.currentSection,
    required this.totalIncidents,
    required this.totalPoints,
  });

  factory StudentSummaryRow.fromJson(Map<String, dynamic> j) {
    int? _n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return StudentSummaryRow(
      id: (j['id'] as num?)?.toInt() ?? 0,
      admissionNo: j['admission_no']?.toString() ?? '',
      rollNo: j['roll_no']?.toString() ?? '',
      firstName: j['first_name']?.toString() ?? '',
      lastName: j['last_name']?.toString() ?? '',
      currentClass: _n(j['current_class']),
      currentSection: _n(j['current_section']),
      totalIncidents: (j['total_incidents'] as num?)?.toInt() ?? 0,
      totalPoints: (j['total_points'] as num?)?.toInt() ?? 0,
    );
  }
}

class StudentRankRow {
  final int studentId;
  final String studentName;
  final String admissionNo;
  final int? classId;
  final int? sectionId;
  final int totalPoints;
  final int totalIncidents;

  const StudentRankRow({
    required this.studentId,
    required this.studentName,
    required this.admissionNo,
    this.classId,
    this.sectionId,
    required this.totalPoints,
    required this.totalIncidents,
  });

  factory StudentRankRow.fromJson(Map<String, dynamic> j) {
    int? _n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return StudentRankRow(
      studentId: (j['student_id'] as num?)?.toInt() ?? 0,
      studentName: j['student_name']?.toString() ?? '',
      admissionNo: j['admission_no']?.toString() ?? '',
      classId: _n(j['class_id']),
      sectionId: _n(j['section_id']),
      totalPoints: (j['total_points'] as num?)?.toInt() ?? 0,
      totalIncidents: (j['total_incidents'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClassSectionRankRow {
  final int? classId;
  final int? sectionId;
  final int totalPoints;
  final int totalIncidents;
  final int studentCount;

  const ClassSectionRankRow({
    this.classId,
    this.sectionId,
    required this.totalPoints,
    required this.totalIncidents,
    required this.studentCount,
  });

  factory ClassSectionRankRow.fromJson(Map<String, dynamic> j) {
    int? _n(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return ClassSectionRankRow(
      classId: _n(j['class_id']),
      sectionId: _n(j['section_id']),
      totalPoints: (j['total_points'] as num?)?.toInt() ?? 0,
      totalIncidents: (j['total_incidents'] as num?)?.toInt() ?? 0,
      studentCount: (j['student_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class IncidentWiseStudent {
  final int studentId;
  final String studentName;
  final int point;
  const IncidentWiseStudent({
    required this.studentId,
    required this.studentName,
    required this.point,
  });
  factory IncidentWiseStudent.fromJson(Map<String, dynamic> j) =>
      IncidentWiseStudent(
        studentId: (j['student_id'] as num?)?.toInt() ?? 0,
        studentName: j['student_name']?.toString() ?? '',
        point: (j['point'] as num?)?.toInt() ?? 0,
      );
}

class IncidentWiseRow {
  final int incidentId;
  final String incidentTitle;
  final int assignmentCount;
  final int totalPoints;
  final List<IncidentWiseStudent> students;

  const IncidentWiseRow({
    required this.incidentId,
    required this.incidentTitle,
    required this.assignmentCount,
    required this.totalPoints,
    required this.students,
  });

  factory IncidentWiseRow.fromJson(Map<String, dynamic> j) {
    final rawStudents = j['students'];
    final students = <IncidentWiseStudent>[];
    if (rawStudents is List) {
      for (final s in rawStudents) {
        if (s is Map<String, dynamic>) {
          students.add(IncidentWiseStudent.fromJson(s));
        }
      }
    }
    return IncidentWiseRow(
      incidentId: (j['incident_id'] as num?)?.toInt() ?? 0,
      incidentTitle: j['incident_title']?.toString() ?? '',
      assignmentCount: (j['assignment_count'] as num?)?.toInt() ?? 0,
      totalPoints: (j['total_points'] as num?)?.toInt() ?? 0,
      students: students,
    );
  }
}
