class StudentGroup {
  final int id;
  final String name;
  final String description;
  final int? studentsCount;

  const StudentGroup({
    required this.id,
    required this.name,
    required this.description,
    this.studentsCount,
  });

  factory StudentGroup.fromJson(Map<String, dynamic> json) => StudentGroup(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        studentsCount: json['students_count'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
