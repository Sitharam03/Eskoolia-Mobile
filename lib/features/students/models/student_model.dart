class StudentRow {
  final int id;
  final String admissionNo;
  final String? rollNo;
  final String firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String gender;
  final String? bloodGroup;
  final int? category;
  final int? guardian;
  final int? currentClass;
  final int? currentSection;
  final bool isDisabled;
  final bool isActive;
  final String? createdAt;

  const StudentRow({
    required this.id,
    required this.admissionNo,
    this.rollNo,
    required this.firstName,
    this.lastName,
    this.dateOfBirth,
    required this.gender,
    this.bloodGroup,
    this.category,
    this.guardian,
    this.currentClass,
    this.currentSection,
    required this.isDisabled,
    required this.isActive,
    this.createdAt,
  });

  String get fullName =>
      [firstName, lastName].where((s) => s != null && s!.isNotEmpty).join(' ');

  String get genderLabel {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return gender;
    }
  }

  factory StudentRow.fromJson(Map<String, dynamic> json) => StudentRow(
        id: json['id'] as int,
        admissionNo: json['admission_no'] as String? ?? '',
        rollNo: json['roll_no'] as String?,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String?,
        dateOfBirth: json['date_of_birth'] as String?,
        gender: json['gender'] as String? ?? '',
        bloodGroup: json['blood_group'] as String?,
        category: json['category'] as int?,
        guardian: json['guardian'] as int?,
        currentClass: json['current_class'] as int?,
        currentSection: json['current_section'] as int?,
        isDisabled: json['is_disabled'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'admission_no': admissionNo,
        if (rollNo != null && rollNo!.isNotEmpty) 'roll_no': rollNo,
        'first_name': firstName,
        if (lastName != null && lastName!.isNotEmpty) 'last_name': lastName,
        if (dateOfBirth != null && dateOfBirth!.isNotEmpty)
          'date_of_birth': dateOfBirth,
        'gender': gender,
        if (bloodGroup != null) 'blood_group': bloodGroup,
        if (category != null) 'category': category,
        if (guardian != null) 'guardian': guardian,
        if (currentClass != null) 'current_class': currentClass,
        if (currentSection != null) 'current_section': currentSection,
        'is_disabled': isDisabled,
        'is_active': isActive,
      };

  StudentRow copyWith({
    int? id,
    String? admissionNo,
    String? rollNo,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? bloodGroup,
    int? category,
    int? guardian,
    int? currentClass,
    int? currentSection,
    bool? isDisabled,
    bool? isActive,
    String? createdAt,
  }) =>
      StudentRow(
        id: id ?? this.id,
        admissionNo: admissionNo ?? this.admissionNo,
        rollNo: rollNo ?? this.rollNo,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        category: category ?? this.category,
        guardian: guardian ?? this.guardian,
        currentClass: currentClass ?? this.currentClass,
        currentSection: currentSection ?? this.currentSection,
        isDisabled: isDisabled ?? this.isDisabled,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
}
