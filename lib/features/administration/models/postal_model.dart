class PostalItem {
  final int id;
  final String fromTitle;
  final String referenceNo;
  final String address;
  final String note;
  final String toTitle;
  final String date;

  const PostalItem({
    required this.id,
    required this.fromTitle,
    required this.referenceNo,
    required this.address,
    required this.note,
    required this.toTitle,
    required this.date,
  });

  factory PostalItem.fromJson(Map<String, dynamic> json) => PostalItem(
        id: json['id'] as int,
        fromTitle: json['from_title'] as String? ?? '',
        referenceNo: json['reference_no'] as String? ?? '',
        address: json['address'] as String? ?? '',
        note: json['note'] as String? ?? '',
        toTitle: json['to_title'] as String? ?? '',
        date: json['date'] as String? ?? '',
      );
}
