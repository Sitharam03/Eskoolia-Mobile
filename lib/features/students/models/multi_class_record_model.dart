class MultiClassRecord {
  final int? id;
  final int schoolClass;
  final int? section;
  final String rollNo;
  final bool isDefault;

  const MultiClassRecord({
    this.id,
    required this.schoolClass,
    this.section,
    this.rollNo = '',
    required this.isDefault,
  });

  factory MultiClassRecord.fromJson(Map<String, dynamic> json) =>
      MultiClassRecord(
        id: json['id'] as int?,
        schoolClass: json['school_class'] as int,
        section: json['section'] as int?,
        rollNo: json['roll_no'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'school_class': schoolClass,
        if (section != null) 'section': section,
        'roll_no': rollNo,
        'is_default': isDefault,
      };

  MultiClassRecord copyWith({
    int? id,
    int? schoolClass,
    int? section,
    String? rollNo,
    bool? isDefault,
  }) =>
      MultiClassRecord(
        id: id ?? this.id,
        schoolClass: schoolClass ?? this.schoolClass,
        section: section ?? this.section,
        rollNo: rollNo ?? this.rollNo,
        isDefault: isDefault ?? this.isDefault,
      );
}
