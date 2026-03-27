class AdminRecipient {
  final int id;
  final String label;
  final String admissionNo;
  final String rollNo;
  final String className;
  final String sectionName;
  final int? classId;
  final int? sectionId;
  final String gender;
  final String dateOfBirth;

  AdminRecipient({
    required this.id,
    required this.label,
    required this.admissionNo,
    required this.rollNo,
    required this.className,
    required this.sectionName,
    this.classId,
    this.sectionId,
    required this.gender,
    required this.dateOfBirth,
  });

  factory AdminRecipient.fromJson(Map<String, dynamic> json) {
    // Attempt to merge first_name + last_name if present, otherwise fallback to "label" from the generate-certificate endpoint.
    final f = json['first_name']?.toString() ?? '';
    final l = json['last_name']?.toString() ?? '';
    final computedLabel = (f + (f.isNotEmpty && l.isNotEmpty ? ' ' : '') + l).trim();
    final finalLabel = computedLabel.isNotEmpty ? computedLabel : (json['label']?.toString() ?? 'Unknown User');

    return AdminRecipient(
      id: json['id'] ?? 0,
      label: finalLabel,
      admissionNo: json['admission_no']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      sectionName: json['sectionName']?.toString() ?? '',
      classId: json['current_class'] != null ? int.tryParse(json['current_class'].toString()) : null,
      sectionId: json['current_section'] != null ? int.tryParse(json['current_section'].toString()) : null,
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? json['dateOfBirth']?.toString() ?? '',
    );
  }
}

// ── Shared Setup Helpers ──

class RoleOption {
  final int id;
  final String name;
  RoleOption(this.id, this.name);
  factory RoleOption.fromJson(Map<String, dynamic> json) => 
      RoleOption(json['id'] ?? 0, json['name']?.toString() ?? '');
}

class ClassOption {
  final int id;
  final String name;
  ClassOption(this.id, this.name);
  factory ClassOption.fromJson(Map<String, dynamic> json) => 
      ClassOption(json['id'] ?? 0, json['class_name']?.toString() ?? json['name']?.toString() ?? '');
}

class SectionOption {
  final int id;
  final int schoolClass;
  final String name;
  SectionOption(this.id, this.schoolClass, this.name);
  factory SectionOption.fromJson(Map<String, dynamic> json) => 
      SectionOption(
        json['id'] ?? 0, 
        json['school_class'] ?? 0, 
        json['section_name']?.toString() ?? json['name']?.toString() ?? ''
      );
}

class GenerateSetupData {
  final List<RoleOption> roles;
  final List<ClassOption> classes;
  final List<SectionOption> sections;

  GenerateSetupData({
    required this.roles,
    required this.classes,
    required this.sections,
  });

  factory GenerateSetupData.fromJson(Map<String, dynamic> json) {
    return GenerateSetupData(
      roles: (json['roles'] as List<dynamic>?)?.map((e) => RoleOption.fromJson(e)).toList() ?? [],
      classes: (json['classes'] as List<dynamic>?)?.map((e) => ClassOption.fromJson(e)).toList() ?? [],
      sections: (json['sections'] as List<dynamic>?)?.map((e) => SectionOption.fromJson(e)).toList() ?? [],
    );
  }
}
