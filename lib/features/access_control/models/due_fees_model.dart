import 'login_access_model.dart';

class DueCriteriaResponse {
  final List<Option> classes;
  final List<SectionOption> sections;

  DueCriteriaResponse({
    required this.classes,
    required this.sections,
  });

  factory DueCriteriaResponse.fromJson(Map<String, dynamic> json) {
    return DueCriteriaResponse(
      classes: (json['classes'] as List?)?.map((e) => Option.fromJson(e)).toList() ?? [],
      sections: (json['sections'] as List?)?.map((e) => SectionOption.fromJson(e)).toList() ?? [],
    );
  }
}

class DueUserRow {
  final String? admissionNo;
  final String? rollNo;
  final String? studentName;
  final String? className;
  final String? sectionName;
  final String? dueAmount;
  final int? studentUserId;
  final bool? studentAccessStatus;
  final String? parentName;
  final int? parentUserId;
  final bool? parentAccessStatus;

  DueUserRow({
    this.admissionNo,
    this.rollNo,
    this.studentName,
    this.className,
    this.sectionName,
    this.dueAmount,
    this.studentUserId,
    this.studentAccessStatus,
    this.parentName,
    this.parentUserId,
    this.parentAccessStatus,
  });

  factory DueUserRow.fromJson(Map<String, dynamic> json) {
    return DueUserRow(
      admissionNo: json['admission_no']?.toString(),
      rollNo: json['roll_no']?.toString(),
      studentName: json['student_name']?.toString(),
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      dueAmount: json['due_amount']?.toString(),
      studentUserId: json['student_user_id'] as int?,
      studentAccessStatus: json['student_access_status'] as bool?,
      parentName: json['parent_name']?.toString(),
      parentUserId: json['parent_user_id'] as int?,
      parentAccessStatus: json['parent_access_status'] as bool?,
    );
  }
}
