class PhoneCallLogItem {
  final int id;
  final String name;
  final String phone;
  final String date;
  final String nextFollowUpDate;
  final String callDuration;
  final String description;
  final String callType; // 'I' = Incoming, 'O' = Outgoing

  const PhoneCallLogItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.date,
    required this.nextFollowUpDate,
    required this.callDuration,
    required this.description,
    required this.callType,
  });

  factory PhoneCallLogItem.fromJson(Map<String, dynamic> json) =>
      PhoneCallLogItem(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        date: json['date'] as String? ?? '',
        nextFollowUpDate: json['next_follow_up_date'] as String? ?? '',
        callDuration: json['call_duration'] as String? ?? '',
        description: json['description'] as String? ?? '',
        callType: json['call_type'] as String? ?? 'I',
      );

  String get callTypeLabel => callType == 'I' ? 'Incoming' : 'Outgoing';
}
