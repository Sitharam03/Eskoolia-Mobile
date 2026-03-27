class Guardian {
  final int id;
  final String fullName;
  final String relation;
  final String phone;
  final String? email;

  const Guardian({
    required this.id,
    required this.fullName,
    required this.relation,
    required this.phone,
    this.email,
  });

  String get displayLabel => '$fullName (${relation.isNotEmpty ? relation : "Guardian"})';

  factory Guardian.fromJson(Map<String, dynamic> json) => Guardian(
        id: json['id'] as int,
        fullName: json['full_name'] as String? ?? '',
        relation: json['relation'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'relation': relation,
        'phone': phone,
        if (email != null && email!.isNotEmpty) 'email': email,
      };
}
