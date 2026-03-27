class AdminSetupItem {
  final int id;
  final String
      type; // '1'=Purpose, '2'=Complaint Type, '3'=Source, '4'=Reference
  final String name;
  final String description;

  const AdminSetupItem({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
  });

  factory AdminSetupItem.fromJson(Map<String, dynamic> json) => AdminSetupItem(
        id: json['id'] as int,
        type: json['type']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  static const Map<String, String> typeLabels = {
    '1': 'Purpose',
    '2': 'Complaint Type',
    '3': 'Source',
    '4': 'Reference',
  };

  String get typeLabel => typeLabels[type] ?? type;
}
