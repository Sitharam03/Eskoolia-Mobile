class Option {
  final int id;
  final String name;

  Option({required this.id, required this.name});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class SectionOption {
  final int id;
  final String name;
  final int classId;

  SectionOption({
    required this.id,
    required this.name,
    required this.classId,
  });

  factory SectionOption.fromJson(Map<String, dynamic> json) {
    return SectionOption(
      id: json['id'] as int,
      name: json['name'] as String,
      classId: json['class_id'] as int,
    );
  }
}

class CriteriaResponse {
  final List<Option> roles;
  final List<Option> classes;
  final List<SectionOption> sections;

  CriteriaResponse({
    required this.roles,
    required this.classes,
    required this.sections,
  });

  factory CriteriaResponse.fromJson(Map<String, dynamic> json) {
    return CriteriaResponse(
      roles: (json['roles'] as List?)?.map((e) => Option.fromJson(e)).toList() ?? [],
      classes: (json['classes'] as List?)?.map((e) => Option.fromJson(e)).toList() ?? [],
      sections: (json['sections'] as List?)?.map((e) => SectionOption.fromJson(e)).toList() ?? [],
    );
  }
}

class LoginUserRow {
  final int userId;
  final String? username;
  final String name;
  final String? email;
  final int? roleId;
  final String? roleName;
  final bool accessStatus;
  final String? staffNo;
  final String? admissionNo;
  final String? rollNo;
  final String? className;
  final String? sectionName;
  final int? parentUserId;
  final String? parentUsername;
  final String? parentName;
  final String? parentEmail;
  final bool? parentAccessStatus;

  LoginUserRow({
    required this.userId,
    this.username,
    required this.name,
    this.email,
    this.roleId,
    this.roleName,
    required this.accessStatus,
    this.staffNo,
    this.admissionNo,
    this.rollNo,
    this.className,
    this.sectionName,
    this.parentUserId,
    this.parentUsername,
    this.parentName,
    this.parentEmail,
    this.parentAccessStatus,
  });

  factory LoginUserRow.fromJson(Map<String, dynamic> json) {
    return LoginUserRow(
      userId: json['user_id'] as int,
      username: json['username']?.toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      roleId: json['role_id'] as int?,
      roleName: json['role_name']?.toString(),
      accessStatus: json['access_status'] == true,
      staffNo: json['staff_no']?.toString(),
      admissionNo: json['admission_no']?.toString(),
      rollNo: json['roll_no']?.toString(),
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      parentUserId: json['parent_user_id'] as int?,
      parentUsername: json['parent_username']?.toString(),
      parentName: json['parent_name']?.toString(),
      parentEmail: json['parent_email']?.toString(),
      parentAccessStatus: json['parent_access_status'] as bool?,
    );
  }
}
