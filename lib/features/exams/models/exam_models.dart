// ── Exam Type ────────────────────────────────────────────────────────────────

class ExamType {
  final int id;
  final String title;
  final bool isAverage;
  final String averageMark;
  final bool activeStatus;

  const ExamType({
    required this.id,
    required this.title,
    required this.isAverage,
    required this.averageMark,
    required this.activeStatus,
  });

  factory ExamType.fromJson(Map<String, dynamic> json) => ExamType(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        isAverage: json['is_average'] == true || json['is_average'] == 'yes',
        averageMark: (json['average_mark'] ?? '0').toString(),
        activeStatus: json['active_status'] == true,
      );
}

// ── Exam Setup ───────────────────────────────────────────────────────────────

class ExamSetupPart {
  final String examTitle;
  final String examMark;

  ExamSetupPart({required this.examTitle, required this.examMark});

  factory ExamSetupPart.fromJson(Map<String, dynamic> json) => ExamSetupPart(
        examTitle: json['exam_title'] as String? ?? '',
        examMark: (json['exam_mark'] ?? '0').toString(),
      );
}

// ── Exam Schedule ────────────────────────────────────────────────────────────

class RoutineRow {
  int? section;
  int subject;
  int? teacherId;
  int? examPeriodId;
  String date;
  String startTime;
  String endTime;
  String room;

  RoutineRow({
    this.section,
    required this.subject,
    this.teacherId,
    this.examPeriodId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  RoutineRow copyWith({
    int? section,
    int? teacherId,
    int? examPeriodId,
    String? date,
    String? startTime,
    String? endTime,
    String? room,
  }) =>
      RoutineRow(
        section: section ?? this.section,
        subject: subject,
        teacherId: teacherId ?? this.teacherId,
        examPeriodId: examPeriodId ?? this.examPeriodId,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        room: room ?? this.room,
      );
}

class ExistingRoutine {
  final int id;
  final String subjectName;
  final String className;
  final String sectionName;
  final String teacherName;
  final String examDate;
  final String startTime;
  final String endTime;
  final String room;

  const ExistingRoutine({
    required this.id,
    required this.subjectName,
    required this.className,
    required this.sectionName,
    required this.teacherName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory ExistingRoutine.fromJson(Map<String, dynamic> json) =>
      ExistingRoutine(
        id: json['id'] as int,
        subjectName: json['subject_name'] as String? ?? '',
        className: json['class_name'] as String? ?? '',
        sectionName: json['section_name'] as String? ?? '',
        teacherName: json['teacher_name'] as String? ?? '',
        examDate: json['exam_date'] as String? ?? '',
        startTime: (json['start_time'] as String? ?? '').substring(0, 5 < (json['start_time'] as String? ?? '').length ? 5 : (json['start_time'] as String? ?? '').length),
        endTime: (json['end_time'] as String? ?? '').substring(0, 5 < (json['end_time'] as String? ?? '').length ? 5 : (json['end_time'] as String? ?? '').length),
        room: json['room'] as String? ?? '',
      );
}

// ── Marks Entry ──────────────────────────────────────────────────────────────

class ExamSetupInfo {
  final int id;
  final String examTitle;
  final String examMark;

  const ExamSetupInfo({
    required this.id,
    required this.examTitle,
    required this.examMark,
  });

  factory ExamSetupInfo.fromJson(Map<String, dynamic> json) => ExamSetupInfo(
        id: json['id'] as int,
        examTitle: json['exam_title'] as String? ?? '',
        examMark: (json['exam_mark'] ?? '0').toString(),
      );
}

class MarksStudentRow {
  final int studentRecordId;
  final int student;
  final int classId;
  final int? section;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;
  final Map<String, String> marks;
  final String teacherRemarks;
  final bool isAbsent;

  const MarksStudentRow({
    required this.studentRecordId,
    required this.student,
    required this.classId,
    this.section,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.rollNo,
    required this.marks,
    required this.teacherRemarks,
    required this.isAbsent,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory MarksStudentRow.fromJson(Map<String, dynamic> json) {
    final rawMarks = json['marks'];
    final Map<String, String> marks = {};
    if (rawMarks is Map) {
      rawMarks.forEach((k, v) => marks[k.toString()] = v.toString());
    }
    return MarksStudentRow(
      studentRecordId: json['student_record_id'] as int,
      student: json['student'] as int,
      classId: json['class'] as int? ?? 0,
      section: json['section'] as int?,
      admissionNo: json['admission_no'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      rollNo: json['roll_no'] as String? ?? '',
      marks: marks,
      teacherRemarks: json['teacher_remarks'] as String? ?? '',
      isAbsent: json['is_absent'] == true,
    );
  }
}

// ── Marks Register Report ────────────────────────────────────────────────────

class MarksRegisterPart {
  final int examSetupId;
  final String marks;

  const MarksRegisterPart({required this.examSetupId, required this.marks});

  factory MarksRegisterPart.fromJson(Map<String, dynamic> json) =>
      MarksRegisterPart(
        examSetupId: json['exam_setup_id'] as int? ?? 0,
        marks: (json['marks'] ?? '0').toString(),
      );
}

class MarksRegisterRow {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;
  final bool isAbsent;
  final String totalMarks;
  final String totalGpaPoint;
  final String totalGpaGrade;
  final String teacherRemarks;
  final List<MarksRegisterPart> parts;

  const MarksRegisterRow({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.rollNo,
    required this.isAbsent,
    required this.totalMarks,
    required this.totalGpaPoint,
    required this.totalGpaGrade,
    required this.teacherRemarks,
    required this.parts,
  });

  String get fullName => '$firstName $lastName'.trim();

  String partValue(int partId) {
    final found = parts.where((p) => p.examSetupId == partId).firstOrNull;
    return found?.marks ?? '0';
  }

  factory MarksRegisterRow.fromJson(Map<String, dynamic> json) {
    final rawParts = json['parts'];
    final List<MarksRegisterPart> parts = rawParts is List
        ? rawParts
            .map((p) => MarksRegisterPart.fromJson(p as Map<String, dynamic>))
            .toList()
        : [];
    return MarksRegisterRow(
      id: json['id'] as int,
      admissionNo: json['admission_no'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      rollNo: json['roll_no'] as String? ?? '',
      isAbsent: json['is_absent'] == true,
      totalMarks: (json['total_marks'] ?? '0').toString(),
      totalGpaPoint: (json['total_gpa_point'] ?? '0').toString(),
      totalGpaGrade: json['total_gpa_grade'] as String? ?? '-',
      teacherRemarks: json['teacher_remarks'] as String? ?? '',
      parts: parts,
    );
  }
}

// ── Shared lookup types ──────────────────────────────────────────────────────

class SchoolClass {
  final int id;
  final String name;
  const SchoolClass({required this.id, required this.name});
  factory SchoolClass.fromJson(Map<String, dynamic> json) => SchoolClass(
        id: json['id'] as int,
        name: json['class_name'] as String? ?? json['name'] as String? ?? 'Class ${json['id']}',
      );
}

class SchoolSection {
  final int id;
  final String name;
  final int? classId;
  const SchoolSection({required this.id, required this.name, this.classId});
  factory SchoolSection.fromJson(Map<String, dynamic> json) => SchoolSection(
        id: json['id'] as int,
        name: json['section_name'] as String? ?? json['name'] as String? ?? 'Section ${json['id']}',
        classId: json['class_id'] as int? ?? json['school_class'] as int?,
      );
}

class SchoolSubject {
  final int id;
  final String name;
  const SchoolSubject({required this.id, required this.name});
  factory SchoolSubject.fromJson(Map<String, dynamic> json) => SchoolSubject(
        id: json['id'] as int,
        name: json['subject_name'] as String? ?? json['name'] as String? ?? 'Subject ${json['id']}',
      );
}

class SchoolTeacher {
  final int id;
  final String fullName;
  const SchoolTeacher({required this.id, required this.fullName});
  factory SchoolTeacher.fromJson(Map<String, dynamic> json) => SchoolTeacher(
        id: json['id'] as int,
        fullName: json['full_name'] as String? ?? '',
      );
}

class ExamPeriod {
  final int id;
  final String period;
  const ExamPeriod({required this.id, required this.period});
  factory ExamPeriod.fromJson(Map<String, dynamic> json) => ExamPeriod(
        id: json['id'] as int,
        period: json['period'] as String? ?? '',
      );
}

// ── Admit Card / Seat Plan ────────────────────────────────────────────────────

class AdmitCardStudent {
  final int studentRecordId;
  final int studentId;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;

  const AdmitCardStudent({
    required this.studentRecordId,
    required this.studentId,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.rollNo,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AdmitCardStudent.fromJson(Map<String, dynamic> json) =>
      AdmitCardStudent(
        studentRecordId: json['student_record_id'] as int,
        studentId: json['student_id'] as int? ?? 0,
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        rollNo: json['roll_no'] as String? ?? '',
      );
}

class AdmitCardSetting {
  final int admitLayout;
  final bool studentPhoto;
  final bool studentName;
  final bool admissionNo;
  final bool classSection;
  final bool examName;
  final bool academicYearLabel;
  final bool schoolName;
  final bool rollNo;

  const AdmitCardSetting({
    required this.admitLayout,
    required this.studentPhoto,
    required this.studentName,
    required this.admissionNo,
    required this.classSection,
    required this.examName,
    required this.academicYearLabel,
    required this.schoolName,
    required this.rollNo,
  });

  factory AdmitCardSetting.fromJson(Map<String, dynamic> json) =>
      AdmitCardSetting(
        admitLayout: json['admit_layout'] as int? ?? 1,
        studentPhoto: json['student_photo'] == true,
        studentName: json['student_name'] == true,
        admissionNo: json['admission_no'] == true,
        classSection: json['class_section'] == true,
        examName: json['exam_name'] == true,
        academicYearLabel: json['academic_year_label'] == true,
        schoolName: json['school_name'] == true,
        rollNo: json['roll_no'] == true,
      );
}

// ── Exam Attendance ───────────────────────────────────────────────────────────

class AttendanceStudent {
  final int studentRecordId;
  final int student;
  final int classId;
  final int? section;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;
  final String attendanceType;

  const AttendanceStudent({
    required this.studentRecordId,
    required this.student,
    required this.classId,
    this.section,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.rollNo,
    required this.attendanceType,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) =>
      AttendanceStudent(
        studentRecordId: json['student_record_id'] as int,
        student: json['student'] as int? ?? 0,
        classId: json['class'] as int? ?? 0,
        section: json['section'] as int?,
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        rollNo: json['roll_no'] as String? ?? '',
        attendanceType: json['attendance_type'] as String? ?? 'P',
      );
}

class AttendanceReportRow {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;
  final String attendanceType;

  const AttendanceReportRow({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.rollNo,
    required this.attendanceType,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isPresent => attendanceType == 'P';

  factory AttendanceReportRow.fromJson(Map<String, dynamic> json) =>
      AttendanceReportRow(
        id: json['id'] as int,
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        rollNo: json['roll_no'] as String? ?? '',
        attendanceType: json['attendance_type'] as String? ?? 'P',
      );
}

// ── Result Publish ────────────────────────────────────────────────────────────

class ResultPublishInfo {
  final String examName;
  final String className;
  final String sectionName;
  final int totalMarkEntries;
  final bool isPublished;
  final String? publishedAt;

  const ResultPublishInfo({
    required this.examName,
    required this.className,
    required this.sectionName,
    required this.totalMarkEntries,
    required this.isPublished,
    this.publishedAt,
  });

  factory ResultPublishInfo.fromJson(Map<String, dynamic> json) {
    final info = json['search_info'] as Map<String, dynamic>? ?? {};
    return ResultPublishInfo(
      examName: info['exam_name'] as String? ?? '',
      className: info['class_name'] as String? ?? '',
      sectionName: info['section_name'] as String? ?? 'All Sections',
      totalMarkEntries: json['total_mark_entries'] as int? ?? 0,
      isPublished: json['is_published'] == true,
      publishedAt: json['published_at'] as String?,
    );
  }
}

// ── Merit Report ──────────────────────────────────────────────────────────────

class MeritRow {
  final int position;
  final String admissionNo;
  final String studentName;
  final String rollNo;
  final int subjectCount;
  final String totalMarks;
  final String averageGpa;

  const MeritRow({
    required this.position,
    required this.admissionNo,
    required this.studentName,
    required this.rollNo,
    required this.subjectCount,
    required this.totalMarks,
    required this.averageGpa,
  });

  factory MeritRow.fromJson(Map<String, dynamic> json) => MeritRow(
        position: json['position'] as int? ?? 0,
        admissionNo: json['admission_no'] as String? ?? '',
        studentName: json['student_name'] as String? ?? '',
        rollNo: json['roll_no'] as String? ?? '',
        subjectCount: json['subject_count'] as int? ?? 0,
        totalMarks: (json['total_marks'] ?? '0').toString(),
        averageGpa: (json['average_gpa'] ?? '0').toString(),
      );
}

// ── Schedule Report ───────────────────────────────────────────────────────────

class ScheduleReportRow {
  final int id;
  final String examDate;
  final String subjectName;
  final String className;
  final String sectionName;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String room;

  const ScheduleReportRow({
    required this.id,
    required this.examDate,
    required this.subjectName,
    required this.className,
    required this.sectionName,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory ScheduleReportRow.fromJson(Map<String, dynamic> json) {
    final st = json['start_time'] as String? ?? '';
    final et = json['end_time'] as String? ?? '';
    return ScheduleReportRow(
      id: json['id'] as int,
      examDate: json['exam_date'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
      sectionName: json['section_name'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      startTime: st.length >= 5 ? st.substring(0, 5) : st,
      endTime: et.length >= 5 ? et.substring(0, 5) : et,
      room: json['room'] as String? ?? '',
    );
  }
}

// ── Student Report ────────────────────────────────────────────────────────────

class StudentReportRow {
  final int subjectId;
  final String subjectName;
  final String totalMarks;
  final String grade;
  final String gpa;
  final bool isAbsent;
  final String remarks;

  const StudentReportRow({
    required this.subjectId,
    required this.subjectName,
    required this.totalMarks,
    required this.grade,
    required this.gpa,
    required this.isAbsent,
    required this.remarks,
  });

  factory StudentReportRow.fromJson(Map<String, dynamic> json) =>
      StudentReportRow(
        subjectId: json['subject_id'] as int? ?? 0,
        subjectName: json['subject_name'] as String? ?? '',
        totalMarks: (json['total_marks'] ?? '0').toString(),
        grade: json['grade'] as String? ?? '-',
        gpa: (json['gpa'] ?? '0').toString(),
        isAbsent: json['is_absent'] == true,
        remarks: json['remarks'] as String? ?? '',
      );
}

class SimpleStudent {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final int? classId;
  final int? sectionId;

  const SimpleStudent({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    this.classId,
    this.sectionId,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayLabel =>
      '${fullName.isNotEmpty ? fullName : 'Student'} ($admissionNo)';

  factory SimpleStudent.fromJson(Map<String, dynamic> json) => SimpleStudent(
        id: json['id'] as int,
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        classId: json['class_id'] as int?,
        sectionId: json['section_id'] as int?,
      );
}

// ── Online Exam ───────────────────────────────────────────────────────────────

class OnlineExam {
  final int id;
  final String title;
  final int classId;
  final String className;
  final int? sectionId;
  final String sectionName;
  final int subjectId;
  final String subjectName;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final int duration;
  final int totalMark;
  final int passMark;
  final int status;
  final String percentage;

  const OnlineExam({
    required this.id,
    required this.title,
    required this.classId,
    required this.className,
    this.sectionId,
    required this.sectionName,
    required this.subjectId,
    required this.subjectName,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalMark,
    required this.passMark,
    required this.status,
    required this.percentage,
  });

  bool get isPublished => status == 1;

  factory OnlineExam.fromJson(Map<String, dynamic> json) {
    final st = json['start_time'] as String? ?? '';
    final et = json['end_time'] as String? ?? '';
    return OnlineExam(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      classId: json['school_class'] as int? ?? json['class_id'] as int? ?? 0,
      className: json['class_name'] as String? ?? '',
      sectionId: json['section'] as int? ?? json['section_id'] as int?,
      sectionName: json['section_name'] as String? ?? '',
      subjectId: json['subject'] as int? ?? json['subject_id'] as int? ?? 0,
      subjectName: json['subject_name'] as String? ?? '',
      startDate: json['start_date'] as String? ?? json['date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? json['date'] as String? ?? '',
      startTime: st.length >= 5 ? st.substring(0, 5) : st,
      endTime: et.length >= 5 ? et.substring(0, 5) : et,
      duration: json['duration'] as int? ?? 0,
      totalMark: json['total_mark'] as int? ?? 0,
      passMark: json['pass_mark'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      percentage: (json['percentage'] ?? '').toString(),
    );
  }
}

class OnlineExamMarkStudent {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;

  const OnlineExamMarkStudent({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.rollNo,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory OnlineExamMarkStudent.fromJson(Map<String, dynamic> json) =>
      OnlineExamMarkStudent(
        id: json['id'] as int,
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        rollNo: (json['roll_no'] ?? '').toString(),
      );
}

class OnlineExamResultStudent {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;
  final String totalMarks;
  final int? status;

  const OnlineExamResultStudent({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    required this.lastName,
    required this.rollNo,
    required this.totalMarks,
    this.status,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory OnlineExamResultStudent.fromJson(Map<String, dynamic> json) =>
      OnlineExamResultStudent(
        id: json['id'] as int,
        admissionNo: json['admission_no'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        rollNo: (json['roll_no'] ?? '').toString(),
        totalMarks: (json['total_marks'] ?? '0').toString(),
        status: json['status'] as int?,
      );
}
