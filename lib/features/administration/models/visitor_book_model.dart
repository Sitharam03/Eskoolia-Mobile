class VisitorBookItem {
  final int id;
  final String purpose;
  final String name;
  final String phone;
  final String visitorId;
  final int noOfPerson;
  final String date;
  final String inTime;
  final String outTime;
  final String createdByName;

  const VisitorBookItem({
    required this.id,
    required this.purpose,
    required this.name,
    required this.phone,
    required this.visitorId,
    required this.noOfPerson,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.createdByName,
  });

  factory VisitorBookItem.fromJson(Map<String, dynamic> json) =>
      VisitorBookItem(
        id: json['id'] as int,
        purpose: json['purpose'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        visitorId: json['visitor_id'] as String? ?? '',
        noOfPerson: (json['no_of_person'] as num?)?.toInt() ?? 1,
        date: json['date'] as String? ?? '',
        inTime: json['in_time'] as String? ?? '',
        outTime: json['out_time'] as String? ?? '',
        createdByName: json['created_by_name'] as String? ?? '',
      );
}
