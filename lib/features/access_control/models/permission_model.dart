class PermissionNode {
  final int id;
  final String code;
  final String name;
  final bool selected;

  PermissionNode({
    required this.id,
    required this.code,
    required this.name,
    required this.selected,
  });

  factory PermissionNode.fromJson(Map<String, dynamic> json) {
    return PermissionNode(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      selected: json['selected'] == true,
    );
  }
}

class ModuleNode {
  final String module;
  final List<PermissionNode> permissions;

  ModuleNode({
    required this.module,
    required this.permissions,
  });

  factory ModuleNode.fromJson(Map<String, dynamic> json) {
    return ModuleNode(
      module: json['module'] as String,
      permissions: (json['permissions'] as List?)
              ?.map((e) => PermissionNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PermissionTreeResponse {
  final Map<String, dynamic>? role;
  final List<ModuleNode> modules;

  PermissionTreeResponse({
    this.role,
    required this.modules,
  });

  factory PermissionTreeResponse.fromJson(Map<String, dynamic> json) {
    return PermissionTreeResponse(
      role: json['role'] as Map<String, dynamic>?,
      modules: (json['modules'] as List?)
              ?.map((e) => ModuleNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
