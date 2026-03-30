class FeesType {
  final int id;
  final int academicYear;
  final int feesGroup;
  final String name;
  final double amount;
  final String description;
  final bool isActive;
  final String createdAt;

  const FeesType({
    required this.id,
    required this.academicYear,
    required this.feesGroup,
    required this.name,
    required this.amount,
    required this.description,
    required this.isActive,
    required this.createdAt,
  });

  static int _toId(dynamic v) {
    if (v is num) return v.toInt();
    if (v is Map) return (v['id'] as num?)?.toInt() ?? 0;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory FeesType.fromJson(Map<String, dynamic> j) => FeesType(
        id: _toId(j['id']),
        academicYear: _toId(j['academic_year']),
        feesGroup: _toId(j['fees_group']),
        name: j['name']?.toString() ?? '',
        amount: double.tryParse(j['amount']?.toString() ?? '0') ?? 0.0,
        description: j['description']?.toString() ?? '',
        isActive: j['is_active'] is bool
            ? j['is_active'] as bool
            : j['is_active']?.toString() == 'true',
        createdAt: j['created_at']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'academic_year': academicYear,
        'fees_group': feesGroup,
        'name': name,
        'amount': amount.toString(),
        'description': description,
        'is_active': isActive,
      };

  FeesType copyWith({
    int? id,
    int? academicYear,
    int? feesGroup,
    String? name,
    double? amount,
    String? description,
    bool? isActive,
    String? createdAt,
  }) =>
      FeesType(
        id: id ?? this.id,
        academicYear: academicYear ?? this.academicYear,
        feesGroup: feesGroup ?? this.feesGroup,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
}
