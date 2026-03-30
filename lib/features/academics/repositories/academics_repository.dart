import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/academics_models.dart';

class AcademicsRepository {
  Dio get _dio => ApiClient.dio;

  List<T> _parseList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Lookups ──────────────────────────────────────────────────────────────
  Future<List<AcademicYear>> getAcademicYears() async {
    final r = await _dio.get('/api/v1/core/academic-years/');
    return _parseList(r.data, AcademicYear.fromJson);
  }

  Future<List<SchoolClass>> getClasses() async {
    final r = await _dio.get('/api/v1/core/classes/');
    return _parseList(r.data, SchoolClass.fromJson);
  }

  Future<List<Section>> getSections() async {
    final r = await _dio.get('/api/v1/core/sections/');
    return _parseList(r.data, Section.fromJson);
  }

  Future<List<Subject>> getSubjects() async {
    final r = await _dio.get('/api/v1/core/subjects/');
    return _parseList(r.data, Subject.fromJson);
  }

  Future<List<Teacher>> getTeachers() async {
    final r =
        await _dio.get('/api/v1/academics/lesson-planners/teachers/');
    return _parseList(r.data, Teacher.fromJson);
  }

  Future<List<ClassPeriod>> getClassPeriods() async {
    final r = await _dio.get('/api/v1/core/class-periods/',
        queryParameters: {'period_type': 'class'});
    return _parseList(r.data, ClassPeriod.fromJson);
  }

  Future<List<ClassRoom>> getClassRooms() async {
    final r = await _dio.get('/api/v1/core/class-rooms/');
    return _parseList(r.data, ClassRoom.fromJson);
  }

  Future<List<StudentRecord>> getStudents() async {
    final r = await _dio.get('/api/v1/students/students/');
    return _parseList(r.data, StudentRecord.fromJson);
  }

  // ── Core Setup CRUD ───────────────────────────────────────────────────────
  Future<void> saveAcademicYear(Map<String, dynamic> payload, {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/core/academic-years/$id/', data: payload);
    } else {
      await _dio.post('/api/v1/core/academic-years/', data: payload);
    }
  }

  Future<void> deleteAcademicYear(int id) async {
    await _dio.delete('/api/v1/core/academic-years/$id/');
  }

  Future<void> saveClass(Map<String, dynamic> payload, {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/core/classes/$id/', data: payload);
    } else {
      await _dio.post('/api/v1/core/classes/', data: payload);
    }
  }

  Future<void> deleteClass(int id) async {
    await _dio.delete('/api/v1/core/classes/$id/');
  }

  Future<void> saveSection(Map<String, dynamic> payload, {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/core/sections/$id/', data: payload);
    } else {
      await _dio.post('/api/v1/core/sections/', data: payload);
    }
  }

  Future<void> deleteSection(int id) async {
    await _dio.delete('/api/v1/core/sections/$id/');
  }

  Future<void> saveSubject(Map<String, dynamic> payload, {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/core/subjects/$id/', data: payload);
    } else {
      await _dio.post('/api/v1/core/subjects/', data: payload);
    }
  }

  Future<void> deleteSubject(int id) async {
    await _dio.delete('/api/v1/core/subjects/$id/');
  }

  // ── Class Teacher Assignment ─────────────────────────────────────────────
  Future<List<ClassTeacherAssignment>> getClassTeachers(
      {String? classId, String? sectionId}) async {
    final params = <String, dynamic>{};
    if (classId != null && classId.isNotEmpty) params['class_id'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) {
      params['section_id'] = sectionId;
    }
    final r = await _dio.get('/api/v1/academics/class-teachers/',
        queryParameters: params.isEmpty ? null : params);
    return _parseList(r.data, ClassTeacherAssignment.fromJson);
  }

  Future<void> saveClassTeacher(Map<String, dynamic> payload,
      {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/academics/class-teachers/$id/',
          data: payload);
    } else {
      await _dio.post('/api/v1/academics/class-teachers/', data: payload);
    }
  }

  Future<void> deleteClassTeacher(int id) async {
    await _dio.delete('/api/v1/academics/class-teachers/$id/');
  }

  // ── Class Subject Assignment ─────────────────────────────────────────────
  Future<List<ClassSubjectAssignment>> getClassSubjects(
      {String? classId, String? sectionId}) async {
    final params = <String, dynamic>{};
    if (classId != null && classId.isNotEmpty) params['class_id'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) {
      params['section_id'] = sectionId;
    }
    final r = await _dio.get('/api/v1/academics/class-subjects/',
        queryParameters: params.isEmpty ? null : params);
    return _parseList(r.data, ClassSubjectAssignment.fromJson);
  }

  Future<void> saveClassSubject(Map<String, dynamic> payload,
      {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/academics/class-subjects/$id/',
          data: payload);
    } else {
      await _dio.post('/api/v1/academics/class-subjects/', data: payload);
    }
  }

  Future<void> deleteClassSubject(int id) async {
    await _dio.delete('/api/v1/academics/class-subjects/$id/');
  }

  // ── Class Room ───────────────────────────────────────────────────────────
  Future<void> saveClassRoom(Map<String, dynamic> payload, {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/core/class-rooms/$id/', data: payload);
    } else {
      await _dio.post('/api/v1/core/class-rooms/', data: payload);
    }
  }

  Future<void> deleteClassRoom(int id) async {
    await _dio.delete('/api/v1/core/class-rooms/$id/');
  }

  // ── Class Routine ────────────────────────────────────────────────────────
  Future<List<ClassRoutineSlot>> getClassRoutines(
      {String? classId, String? sectionId, String? day}) async {
    final params = <String, dynamic>{};
    if (classId != null && classId.isNotEmpty) params['class_id'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) {
      params['section_id'] = sectionId;
    }
    if (day != null && day.isNotEmpty) params['day'] = day;
    final r = await _dio.get('/api/v1/academics/class-routines/',
        queryParameters: params.isEmpty ? null : params);
    return _parseList(r.data, ClassRoutineSlot.fromJson);
  }

  Future<void> saveClassRoutine(Map<String, dynamic> payload,
      {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/academics/class-routines/$id/',
          data: payload);
    } else {
      await _dio.post('/api/v1/academics/class-routines/', data: payload);
    }
  }

  Future<void> deleteClassRoutine(int id) async {
    await _dio.delete('/api/v1/academics/class-routines/$id/');
  }

  // ── Homework ─────────────────────────────────────────────────────────────
  Future<List<Homework>> getHomeworks(
      {String? classId, String? sectionId, String? subjectId}) async {
    final params = <String, dynamic>{};
    if (classId != null && classId.isNotEmpty) params['class_id'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) {
      params['section_id'] = sectionId;
    }
    if (subjectId != null && subjectId.isNotEmpty) {
      params['subject_id'] = subjectId;
    }
    final r = await _dio.get('/api/v1/academics/homeworks/',
        queryParameters: params.isEmpty ? null : params);
    return _parseList(r.data, Homework.fromJson);
  }

  Future<void> createHomework(Map<String, dynamic> payload) async {
    await _dio.post('/api/v1/academics/homeworks/', data: payload);
  }

  Future<void> patchHomework(int id, Map<String, dynamic> payload) async {
    await _dio.patch('/api/v1/academics/homeworks/$id/', data: payload);
  }

  Future<void> deleteHomework(int id) async {
    await _dio.delete('/api/v1/academics/homeworks/$id/');
  }

  Future<List<HomeworkSubmission>> getHomeworkSubmissions(
      int homeworkId) async {
    final r = await _dio.get('/api/v1/academics/homework-submissions/',
        queryParameters: {'homework_id': homeworkId});
    return _parseList(r.data, HomeworkSubmission.fromJson);
  }

  Future<void> saveHomeworkSubmission(Map<String, dynamic> payload,
      {int? id}) async {
    if (id != null) {
      await _dio.patch('/api/v1/academics/homework-submissions/$id/',
          data: payload);
    } else {
      await _dio.post('/api/v1/academics/homework-submissions/',
          data: payload);
    }
  }

  // ── Upload Content ───────────────────────────────────────────────────────
  Future<List<UploadedContent>> getUploadedContents(
      {String? classId, String? sectionId, String? contentType}) async {
    final params = <String, dynamic>{};
    if (classId != null && classId.isNotEmpty) params['class_id'] = classId;
    if (sectionId != null && sectionId.isNotEmpty) {
      params['section_id'] = sectionId;
    }
    if (contentType != null && contentType.isNotEmpty) {
      params['content_type'] = contentType;
    }
    final r = await _dio.get('/api/v1/academics/upload-contents/',
        queryParameters: params.isEmpty ? null : params);
    return _parseList(r.data, UploadedContent.fromJson);
  }

  Future<void> createUploadedContent(Map<String, dynamic> payload) async {
    await _dio.post('/api/v1/academics/upload-contents/', data: payload);
  }

  Future<void> patchUploadedContent(
      int id, Map<String, dynamic> payload) async {
    await _dio.patch('/api/v1/academics/upload-contents/$id/',
        data: payload);
  }

  Future<void> deleteUploadedContent(int id) async {
    await _dio.delete('/api/v1/academics/upload-contents/$id/');
  }

  // ── Lessons ──────────────────────────────────────────────────────────────
  Future<List<Lesson>> getLessons({String? classId}) async {
    final params =
        classId != null && classId.isNotEmpty ? {'class_id': classId} : null;
    final r = await _dio.get('/api/v1/academics/lessons/',
        queryParameters: params);
    return _parseList(r.data, Lesson.fromJson);
  }

  Future<List<LessonGroup>> getLessonGroups() async {
    final r = await _dio.get('/api/v1/academics/lessons/grouped/');
    if (r.data is List) {
      return (r.data as List)
          .map((e) => LessonGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> createLessons(Map<String, dynamic> payload) async {
    await _dio.post('/api/v1/academics/lessons/', data: payload);
  }

  Future<void> updateLesson(int id, Map<String, dynamic> payload) async {
    await _dio.put('/api/v1/academics/lessons/$id/', data: payload);
  }

  Future<void> deleteLesson(int id) async {
    await _dio.delete('/api/v1/academics/lessons/$id/');
  }

  Future<void> deleteLessonGroup(
      {required String classId,
      required String sectionId,
      required String subjectId}) async {
    await _dio.delete('/api/v1/academics/lessons/delete-group/',
        queryParameters: {
          'class_id': classId,
          'section_id': sectionId,
          'subject_id': subjectId
        });
  }

  // ── Lesson Topics ─────────────────────────────────────────────────────────
  Future<List<LessonTopicGroup>> getLessonTopicGroups() async {
    final r = await _dio.get('/api/v1/academics/lesson-topics/');
    return _parseList(r.data, LessonTopicGroup.fromJson);
  }

  Future<List<LessonTopicDetail>> getLessonTopicDetails() async {
    final r = await _dio.get('/api/v1/academics/lesson-topic-details/');
    return _parseList(r.data, LessonTopicDetail.fromJson);
  }

  Future<void> createLessonTopics(Map<String, dynamic> payload) async {
    await _dio.post('/api/v1/academics/lesson-topics/', data: payload);
  }

  Future<void> patchLessonTopicDetail(
      int id, Map<String, dynamic> payload) async {
    await _dio.patch('/api/v1/academics/lesson-topic-details/$id/',
        data: payload);
  }

  Future<void> deleteLessonTopicDetail(int id) async {
    await _dio.delete('/api/v1/academics/lesson-topic-details/$id/');
  }

  Future<void> deleteLessonTopicGroup(int groupId) async {
    await _dio.delete('/api/v1/academics/lesson-topics/delete-group/',
        queryParameters: {'id': groupId});
  }

  // ── Lesson Planner ───────────────────────────────────────────────────────
  Future<List<PlannerRow>> getLessonPlanners() async {
    final r = await _dio.get('/api/v1/academics/lesson-planners/');
    return _parseList(r.data, PlannerRow.fromJson);
  }

  Future<List<PlannerRow>> getLessonPlannerOverview() async {
    final r =
        await _dio.get('/api/v1/academics/lesson-planners/overview/');
    if (r.data is List) {
      return (r.data as List)
          .map((e) => PlannerRow.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<WeeklyPlanner?> getLessonPlannerWeekly(
      {String? teacherId, String? startDate}) async {
    final params = <String, dynamic>{};
    if (teacherId != null && teacherId.isNotEmpty) {
      params['teacher_id'] = teacherId;
    }
    if (startDate != null && startDate.isNotEmpty) {
      params['start_date'] = startDate;
    }
    final r = await _dio.get('/api/v1/academics/lesson-planners/weekly/',
        queryParameters: params.isEmpty ? null : params);
    if (r.data is Map<String, dynamic>) {
      return WeeklyPlanner.fromJson(r.data as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> createLessonPlanner(Map<String, dynamic> payload) async {
    await _dio.post('/api/v1/academics/lesson-planners/', data: payload);
  }

  Future<void> updateLessonPlanner(
      int id, Map<String, dynamic> payload) async {
    await _dio.put('/api/v1/academics/lesson-planners/$id/', data: payload);
  }

  Future<void> deleteLessonPlanner(int id) async {
    await _dio.delete('/api/v1/academics/lesson-planners/$id/');
  }
}
