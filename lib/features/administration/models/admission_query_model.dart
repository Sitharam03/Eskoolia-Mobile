class AdmissionQueryItem {
  final int id;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String description;
  final String queryDate;
  final String className;
  final String sourceName;
  final String referenceName;
  final int? sourceId;
  final int? referenceId;
  final String assigned;
  final String note;
  final String status; // new/contacted/visited/enrolled/declined
  final int activeStatus; // 1=active etc.
  final int noOfChild;

  const AdmissionQueryItem({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.description,
    required this.queryDate,
    required this.className,
    required this.sourceName,
    required this.referenceName,
    this.sourceId,
    this.referenceId,
    required this.assigned,
    required this.note,
    required this.status,
    required this.activeStatus,
    required this.noOfChild,
  });

  factory AdmissionQueryItem.fromJson(Map<String, dynamic> json) =>
      AdmissionQueryItem(
        id: json['id'] as int,
        fullName: json['full_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        address: json['address'] as String? ?? '',
        description: json['description'] as String? ?? '',
        queryDate: json['query_date'] as String? ?? '',
        className: json['class_name'] as String? ??
            json['class_name_resolved'] as String? ??
            '',
        sourceName: json['source_name'] as String? ?? '',
        referenceName: json['reference_name'] as String? ?? '',
        sourceId: (json['source'] as num?)?.toInt(),
        referenceId: (json['reference'] as num?)?.toInt(),
        assigned: json['assigned'] as String? ?? '',
        note: json['note'] as String? ?? '',
        status: json['status'] as String? ?? 'new',
        activeStatus: (json['active_status'] as num?)?.toInt() ?? 1,
        noOfChild: (json['no_of_child'] as num?)?.toInt() ?? 1,
      );

  static const Map<String, String> statusLabels = {
    'new': 'New',
    'contacted': 'Contacted',
    'visited': 'Visited',
    'enrolled': 'Enrolled',
    'declined': 'Declined',
  };
  String get statusLabel => statusLabels[status] ?? status;
}
