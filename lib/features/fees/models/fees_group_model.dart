class FeesGroup {
  final int id;
  final int academicYear;
  final String name;
  final String description;
  final bool isActive;
  final String createdAt;

  const FeesGroup({
    required this.id,
    required this.academicYear,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory FeesGroup.fromJson(Map<String, dynamic> j) => FeesGroup(
        id: (j['id'] as num?)?.toInt() ?? 0,
        academicYear: (j['academic_year'] is num)
            ? (j['academic_year'] as num).toInt()
            : (j['academic_year'] is Map)
                ? ((j['academic_year'] as Map)['id'] as num?)?.toInt() ?? 0
                : int.tryParse(j['academic_year']?.toString() ?? '') ?? 0,
        name: j['name']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        isActive: j['is_active'] is bool
            ? j['is_active'] as bool
            : j['is_active']?.toString() == 'true',
        createdAt: j['created_at']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'academic_year': academicYear,
        'name': name,
        'description': description,
        'is_active': isActive,
      };

  FeesGroup copyWith({
    int? id,
    int? academicYear,
    String? name,
    String? description,
    bool? isActive,
    String? createdAt,
  }) =>
      FeesGroup(
        id: id ?? this.id,
        academicYear: academicYear ?? this.academicYear,
        name: name ?? this.name,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
}
