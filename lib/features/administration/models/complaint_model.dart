class ComplaintItem {
  final int id;
  final String complaintBy;
  final String complaintType;
  final String complaintSource;
  final String phone;
  final String date;
  final String actionTaken;
  final String assigned;
  final String description;

  const ComplaintItem({
    required this.id,
    required this.complaintBy,
    required this.complaintType,
    required this.complaintSource,
    required this.phone,
    required this.date,
    required this.actionTaken,
    required this.assigned,
    required this.description,
  });

  factory ComplaintItem.fromJson(Map<String, dynamic> json) => ComplaintItem(
        id: json['id'] as int,
        complaintBy: json['complaint_by'] as String? ?? '',
        complaintType: json['complaint_type'] as String? ?? '',
        complaintSource: json['complaint_source'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        date: json['date'] as String? ?? '',
        actionTaken: json['action_taken'] as String? ?? '',
        assigned: json['assigned'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}
