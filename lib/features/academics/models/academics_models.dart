// All academic models in one file

class AcademicYear {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  AcademicYear({required this.id, required this.name, required this.startDate, required this.endDate, required this.isCurrent});
  factory AcademicYear.fromJson(Map<String, dynamic> j) => AcademicYear(
      id: j['id'],
      name: j['name'] ?? '',
      startDate: j['start_date'] ?? '',
      endDate: j['end_date'] ?? '',
      isCurrent: j['is_current'] ?? false);
}

class SchoolClass {
  final int id;
  final String name;
  final int numericOrder;
  final List<Section> sections;
  SchoolClass({required this.id, required this.name, required this.numericOrder, this.sections = const []});
  factory SchoolClass.fromJson(Map<String, dynamic> j) => SchoolClass(
      id: j['id'],
      name: j['name'] ?? '',
      numericOrder: j['numeric_order'] ?? 0,
      sections: j['sections'] != null
          ? (j['sections'] as List).map((s) => Section.fromJson(s as Map<String, dynamic>)).toList()
          : []);
}

class Section {
  final int id;
  final int schoolClass;
  final String name;
  final int capacity;
  Section({required this.id, required this.schoolClass, required this.name, required this.capacity});
  factory Section.fromJson(Map<String, dynamic> j) => Section(
      id: j['id'], schoolClass: j['school_class'] ?? 0, name: j['name'] ?? '', capacity: j['capacity'] ?? 0);
}

class Subject {
  final int id;
  final String name;
  final String code;
  final String subjectType;
  Subject({required this.id, required this.name, required this.code, required this.subjectType});
  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
      id: j['id'], name: j['name'] ?? '', code: j['code'] ?? '', subjectType: j['subject_type'] ?? 'compulsory');
}

class Teacher {
  final int id;
  final String username;
  final String fullName;
  Teacher({required this.id, required this.username, required this.fullName});
  String get displayName => fullName.isNotEmpty ? fullName : username;
  factory Teacher.fromJson(Map<String, dynamic> j) => Teacher(
      id: j['id'],
      username: j['username'] ?? '',
      fullName: j['full_name'] ?? '');
}

class ClassPeriod {
  final int id;
  final String period;
  final String startTime;
  final String endTime;
  ClassPeriod(
      {required this.id,
      required this.period,
      required this.startTime,
      required this.endTime});
  String get label => '$period ($startTime-$endTime)';
  factory ClassPeriod.fromJson(Map<String, dynamic> j) => ClassPeriod(
      id: j['id'],
      period: j['period'] ?? '',
      startTime: j['start_time'] ?? '',
      endTime: j['end_time'] ?? '');
}

class ClassRoom {
  final int id;
  final String roomNo;
  final int? capacity;
  final bool activeStatus;
  ClassRoom(
      {required this.id,
      required this.roomNo,
      this.capacity,
      required this.activeStatus});
  factory ClassRoom.fromJson(Map<String, dynamic> j) => ClassRoom(
      id: j['id'],
      roomNo: j['room_no'] ?? '',
      capacity: j['capacity'],
      activeStatus: j['active_status'] ?? true);
}

class ClassTeacherAssignment {
  final int id;
  final int? academicYearId;
  final int classId;
  final int? sectionId;
  final int teacherId;
  final bool activeStatus;
  ClassTeacherAssignment(
      {required this.id,
      this.academicYearId,
      required this.classId,
      this.sectionId,
      required this.teacherId,
      required this.activeStatus});
  factory ClassTeacherAssignment.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    return ClassTeacherAssignment(
        id: j['id'],
        academicYearId:
            toNullId(j['academic_year_id'] ?? j['academic_year']),
        classId: toId(j['class_id'] ?? j['school_class']),
        sectionId: toNullId(j['section_id'] ?? j['section']),
        teacherId: toId(j['teacher_id'] ?? j['teacher']),
        activeStatus: j['active_status'] ?? true);
  }
}

class ClassSubjectAssignment {
  final int id;
  final int? academicYearId;
  final int classId;
  final int? sectionId;
  final int subjectId;
  final int? teacherId;
  final bool isOptional;
  final bool activeStatus;
  ClassSubjectAssignment(
      {required this.id,
      this.academicYearId,
      required this.classId,
      this.sectionId,
      required this.subjectId,
      this.teacherId,
      required this.isOptional,
      required this.activeStatus});
  factory ClassSubjectAssignment.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    return ClassSubjectAssignment(
        id: j['id'],
        academicYearId:
            toNullId(j['academic_year_id'] ?? j['academic_year']),
        classId: toId(j['class_id'] ?? j['school_class']),
        sectionId: toNullId(j['section_id'] ?? j['section']),
        subjectId: toId(j['subject_id'] ?? j['subject']),
        teacherId: toNullId(j['teacher_id'] ?? j['teacher']),
        isOptional: j['is_optional'] ?? false,
        activeStatus: j['active_status'] ?? true);
  }
}

class ClassRoutineSlot {
  final int id;
  final int? academicYearId;
  final int classId;
  final int? sectionId;
  final int subjectId;
  final int? teacherId;
  final String day;
  final int? classPeriodId;
  final String startTime;
  final String endTime;
  final int? roomId;
  final String room;
  final bool isBreak;
  final bool activeStatus;
  ClassRoutineSlot(
      {required this.id,
      this.academicYearId,
      required this.classId,
      this.sectionId,
      required this.subjectId,
      this.teacherId,
      required this.day,
      this.classPeriodId,
      required this.startTime,
      required this.endTime,
      this.roomId,
      required this.room,
      required this.isBreak,
      required this.activeStatus});
  factory ClassRoutineSlot.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    return ClassRoutineSlot(
        id: j['id'],
        academicYearId: toNullId(j['academic_year_id']),
        classId: toId(j['class_id'] ?? j['school_class']),
        sectionId: toNullId(j['section_id'] ?? j['section']),
        subjectId: toId(j['subject_id'] ?? j['subject']),
        teacherId: toNullId(j['teacher_id'] ?? j['teacher']),
        day: j['day'] ?? 'monday',
        classPeriodId: toNullId(j['class_period_id']),
        startTime: j['start_time'] ?? '',
        endTime: j['end_time'] ?? '',
        roomId: toNullId(j['room_id']),
        room: j['room'] ?? '',
        isBreak: j['is_break'] ?? false,
        activeStatus: j['active_status'] ?? true);
  }
}

class Homework {
  final int id;
  final int? academicYearId;
  final int classId;
  final int? sectionId;
  final int subjectId;
  final String homeworkDate;
  final String submissionDate;
  final String? evaluationDate;
  final dynamic marks;
  final String description;
  final String? file;
  Homework(
      {required this.id,
      this.academicYearId,
      required this.classId,
      this.sectionId,
      required this.subjectId,
      required this.homeworkDate,
      required this.submissionDate,
      this.evaluationDate,
      required this.marks,
      required this.description,
      this.file});
  factory Homework.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    return Homework(
        id: j['id'],
        academicYearId: toNullId(j['academic_year_id']),
        classId: toId(j['class_id']),
        sectionId: toNullId(j['section_id']),
        subjectId: toId(j['subject_id']),
        homeworkDate: j['homework_date'] ?? '',
        submissionDate: j['submission_date'] ?? '',
        evaluationDate: j['evaluation_date'],
        marks: j['marks'] ?? 0,
        description: j['description'] ?? '',
        file: j['file']);
  }
}

class HomeworkSubmission {
  final int id;
  final int homeworkId;
  final int studentId;
  final dynamic marks;
  final String completeStatus; // C, I, P
  final String note;
  HomeworkSubmission(
      {required this.id,
      required this.homeworkId,
      required this.studentId,
      required this.marks,
      required this.completeStatus,
      required this.note});
  factory HomeworkSubmission.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    return HomeworkSubmission(
        id: j['id'],
        homeworkId: toId(j['homework_id'] ?? j['homework']),
        studentId: toId(j['student_id'] ?? j['student']),
        marks: j['marks'] ?? 0,
        completeStatus: j['complete_status'] ?? 'P',
        note: j['note'] ?? '');
  }
}

class UploadedContent {
  final int id;
  final int? academicYearId;
  final int? classId;
  final int? sectionId;
  final String contentTitle;
  final String contentType; // as, st, sy, ot
  final bool availableForAdmin;
  final bool availableForAllClasses;
  final String uploadDate;
  final String description;
  final String sourceUrl;
  final String uploadFile;
  UploadedContent(
      {required this.id,
      this.academicYearId,
      this.classId,
      this.sectionId,
      required this.contentTitle,
      required this.contentType,
      required this.availableForAdmin,
      required this.availableForAllClasses,
      required this.uploadDate,
      required this.description,
      required this.sourceUrl,
      required this.uploadFile});
  String get contentTypeLabel {
    switch (contentType) {
      case 'as':
        return 'Assignment';
      case 'st':
        return 'Study Material';
      case 'sy':
        return 'Syllabus';
      case 'ot':
        return 'Other Downloads';
      default:
        return contentType;
    }
  }

  factory UploadedContent.fromJson(Map<String, dynamic> j) {
    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    return UploadedContent(
        id: j['id'],
        academicYearId: toNullId(j['academic_year_id']),
        classId: toNullId(j['class_id']),
        sectionId: toNullId(j['section_id']),
        contentTitle: j['content_title'] ?? '',
        contentType: j['content_type'] ?? 'as',
        availableForAdmin: j['available_for_admin'] ?? false,
        availableForAllClasses: j['available_for_all_classes'] ?? false,
        uploadDate: j['upload_date'] ?? '',
        description: j['description'] ?? '',
        sourceUrl: j['source_url'] ?? '',
        uploadFile: j['upload_file'] ?? '');
  }
}

class Lesson {
  final int id;
  final int? academicYearId;
  final int? classId;
  final int? sectionId;
  final int? subjectId;
  final String lessonTitle;
  Lesson(
      {required this.id,
      this.academicYearId,
      this.classId,
      this.sectionId,
      this.subjectId,
      required this.lessonTitle});
  factory Lesson.fromJson(Map<String, dynamic> j) {
    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    return Lesson(
        id: j['id'],
        academicYearId: toNullId(j['academic_year_id']),
        classId: toNullId(j['class_id']),
        sectionId: toNullId(j['section_id']),
        subjectId: toNullId(j['subject_id']),
        lessonTitle: j['lesson_title'] ?? '');
  }

  Map<String, dynamic> toJson() => {
        'academic_year_id': academicYearId,
        'class_id': classId,
        'section_id': sectionId,
        'subject_id': subjectId,
        'lesson_title': lessonTitle
      };
}

class LessonGroup {
  final int? classId;
  final int? sectionId;
  final int? subjectId;
  final List<Lesson> items;
  LessonGroup(
      {this.classId, this.sectionId, this.subjectId, required this.items});
  factory LessonGroup.fromJson(Map<String, dynamic> j) {
    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final rawItems = j['items'];
    return LessonGroup(
        classId: toNullId(j['class_id']),
        sectionId: toNullId(j['section_id']),
        subjectId: toNullId(j['subject_id']),
        items: rawItems is List
            ? rawItems
                .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
                .toList()
            : []);
  }
}

class LessonTopicDetail {
  final int id;
  final int topic;
  final int lesson;
  final String topicTitle;
  LessonTopicDetail(
      {required this.id,
      required this.topic,
      required this.lesson,
      required this.topicTitle});
  factory LessonTopicDetail.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    return LessonTopicDetail(
        id: j['id'],
        topic: toId(j['topic']),
        lesson: toId(j['lesson']),
        topicTitle: j['topic_title'] ?? '');
  }
}

class LessonTopicGroup {
  final int id;
  final int? classId;
  final int? sectionId;
  final int? subjectId;
  final int? lessonId;
  final List<LessonTopicDetail> topics;
  LessonTopicGroup(
      {required this.id,
      this.classId,
      this.sectionId,
      this.subjectId,
      this.lessonId,
      required this.topics});
  factory LessonTopicGroup.fromJson(Map<String, dynamic> j) {
    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    final rawTopics = j['topics'];
    return LessonTopicGroup(
        id: j['id'],
        classId: toNullId(j['class_id']),
        sectionId: toNullId(j['section_id']),
        subjectId: toNullId(j['subject_id']),
        lessonId: toNullId(j['lesson_id']),
        topics: rawTopics is List
            ? rawTopics
                .map((e) =>
                    LessonTopicDetail.fromJson(e as Map<String, dynamic>))
                .toList()
            : []);
  }
}

class PlannerTopicRow {
  final int id;
  final int topicId;
  final String subTopicTitle;
  PlannerTopicRow(
      {required this.id,
      required this.topicId,
      required this.subTopicTitle});
  factory PlannerTopicRow.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    return PlannerTopicRow(
        id: j['id'],
        topicId: toId(j['topic_id'] ?? j['topic']),
        subTopicTitle: j['sub_topic_title'] ?? '');
  }
}

class PlannerRow {
  final int id;
  final String lessonDate;
  final int? day;
  final int lessonDetailId;
  final int? topicDetailId;
  final String subTopic;
  final int? teacherId;
  final int classId;
  final int? sectionId;
  final int subjectId;
  final int? routineId;
  final int? classPeriodId;
  final int? academicYearId;
  final List<PlannerTopicRow> topics;
  PlannerRow(
      {required this.id,
      required this.lessonDate,
      this.day,
      required this.lessonDetailId,
      this.topicDetailId,
      required this.subTopic,
      this.teacherId,
      required this.classId,
      this.sectionId,
      required this.subjectId,
      this.routineId,
      this.classPeriodId,
      this.academicYearId,
      required this.topics});
  factory PlannerRow.fromJson(Map<String, dynamic> j) {
    int toId(dynamic v) {
      if (v is int) return v;
      if (v is Map) return v['id'] ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    }

    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is Map) return v['id'];
      return int.tryParse(v.toString());
    }

    final rawTopics = j['topics'];
    return PlannerRow(
        id: j['id'],
        lessonDate: j['lesson_date'] ?? '',
        day: toNullId(j['day']),
        lessonDetailId: toId(j['lesson_detail_id'] ?? j['lesson']),
        topicDetailId: toNullId(j['topic_detail_id']),
        subTopic: j['sub_topic'] ?? '',
        teacherId: toNullId(j['teacher_id']),
        classId: toId(j['class_id']),
        sectionId: toNullId(j['section_id']),
        subjectId: toId(j['subject_id']),
        routineId: toNullId(j['routine_id']),
        classPeriodId: toNullId(j['class_period_id']),
        academicYearId: toNullId(j['academic_year_id']),
        topics: rawTopics is List
            ? rawTopics
                .map((e) =>
                    PlannerTopicRow.fromJson(e as Map<String, dynamic>))
                .toList()
            : []);
  }
}

class WeeklyPlanner {
  final String startDate;
  final String endDate;
  final Map<String, List<PlannerRow>> days;
  WeeklyPlanner(
      {required this.startDate,
      required this.endDate,
      required this.days});
  factory WeeklyPlanner.fromJson(Map<String, dynamic> j) {
    final rawDays = j['days'] as Map<String, dynamic>? ?? {};
    final days = <String, List<PlannerRow>>{};
    rawDays.forEach((key, value) {
      if (value is List) {
        days[key] = value
            .map((e) => PlannerRow.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    });
    return WeeklyPlanner(
        startDate: j['start_date'] ?? '',
        endDate: j['end_date'] ?? '',
        days: days);
  }
}

class StudentRecord {
  final int id;
  final String admissionNo;
  final String firstName;
  final String lastName;
  final String rollNo;
  final int? currentClass;
  final int? currentSection;
  StudentRecord(
      {required this.id,
      required this.admissionNo,
      required this.firstName,
      required this.lastName,
      required this.rollNo,
      this.currentClass,
      this.currentSection});
  String get fullName => '$firstName $lastName';
  factory StudentRecord.fromJson(Map<String, dynamic> j) {
    int? toNullId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return StudentRecord(
        id: j['id'],
        admissionNo: j['admission_no'] ?? '',
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'] ?? '',
        rollNo: j['roll_no'] ?? '',
        currentClass: toNullId(j['current_class']),
        currentSection: toNullId(j['current_section']));
  }
}
