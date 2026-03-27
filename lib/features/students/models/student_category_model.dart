class StudentCategory {
  final int id;
  final String name;
  final String description;

  const StudentCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  factory StudentCategory.fromJson(Map<String, dynamic> json) =>
      StudentCategory(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
