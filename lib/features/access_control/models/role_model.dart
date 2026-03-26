class RoleItem {
  final int id;
  final String name;
  final bool isSystem;
  final String? createdAt;

  RoleItem({
    required this.id,
    required this.name,
    required this.isSystem,
    this.createdAt,
  });

  factory RoleItem.fromJson(Map<String, dynamic> json) {
    return RoleItem(
      id: json['id'] as int,
      name: json['name'] as String,
      isSystem: json['is_system'] == true,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_system': isSystem,
      'created_at': createdAt,
    };
  }
}

class RoleApiResult {
  final List<RoleItem> results;

  RoleApiResult({required this.results});

  factory RoleApiResult.fromJson(dynamic json) {
    if (json is List) {
      return RoleApiResult(
        results: json.map((e) => RoleItem.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } else if (json is Map<String, dynamic> && json.containsKey('results')) {
      return RoleApiResult(
        results: (json['results'] as List)
            .map((e) => RoleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return RoleApiResult(results: []);
  }
}
