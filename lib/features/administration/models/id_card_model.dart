class IdCardTemplate {
  final int id;
  final String title;
  final String pageLayoutStyle;
  final List<int> applicableRoleIds;
  final String backgroundUrl;
  final String logoUrl;
  final String profileUrl;
  final String signatureUrl;
  final double? plWidth;
  final double? plHeight;

  IdCardTemplate({
    required this.id,
    required this.title,
    required this.pageLayoutStyle,
    required this.applicableRoleIds,
    required this.backgroundUrl,
    required this.logoUrl,
    required this.profileUrl,
    required this.signatureUrl,
    required this.plWidth,
    required this.plHeight,
  });

  factory IdCardTemplate.fromJson(Map<String, dynamic> json) {
    return IdCardTemplate(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      pageLayoutStyle: json['page_layout_style']?.toString() ?? 'horizontal',
      applicableRoleIds: (json['applicable_role_ids'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ?? [],
      backgroundUrl: json['background_url']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ?? '',
      profileUrl: json['profile_url']?.toString() ?? '',
      signatureUrl: json['signature_url']?.toString() ?? '',
      plWidth: double.tryParse(json['pl_width']?.toString() ?? ''),
      plHeight: double.tryParse(json['pl_height']?.toString() ?? ''),
    );
  }
}
