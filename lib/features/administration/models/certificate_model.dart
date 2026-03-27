class CertificateTemplate {
  final int id;
  final String title;
  final String type;
  final int? applicableRoleId;
  final String body;
  final double backgroundHeight;
  final double backgroundWidth;
  final double paddingTop;
  final double paddingRight;
  final double paddingBottom;
  final double paddingLeft;
  final String backgroundUrl;

  CertificateTemplate({
    required this.id,
    required this.title,
    required this.type,
    required this.applicableRoleId,
    required this.body,
    required this.backgroundHeight,
    required this.backgroundWidth,
    required this.paddingTop,
    required this.paddingRight,
    required this.paddingBottom,
    required this.paddingLeft,
    required this.backgroundUrl,
  });

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) {
    return CertificateTemplate(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'School',
      applicableRoleId: json['applicable_role_id'] != null 
          ? int.tryParse(json['applicable_role_id'].toString()) 
          : null,
      body: json['body']?.toString() ?? '',
      backgroundHeight: double.tryParse(json['background_height']?.toString() ?? '') ?? 144.0,
      backgroundWidth: double.tryParse(json['background_width']?.toString() ?? '') ?? 165.0,
      paddingTop: double.tryParse(json['padding_top']?.toString() ?? '') ?? 5.0,
      paddingRight: double.tryParse(json['padding_right']?.toString() ?? '') ?? 5.0,
      paddingBottom: double.tryParse(json['padding_bottom']?.toString() ?? '') ?? 5.0,
      // Note the typo in the backend API as seen in React 'pading_left'
      paddingLeft: double.tryParse(json['pading_left']?.toString() ?? json['padding_left']?.toString() ?? '') ?? 5.0,
      backgroundUrl: json['background_url']?.toString() ?? '',
    );
  }
}
