import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/upload_content_controller.dart';
import '../models/academics_models.dart';
import '_academics_nav_tabs.dart';
import '_academics_shared.dart';

class ContentListView extends StatefulWidget {
  final String title;
  final String? lockedType;
  const ContentListView({super.key, required this.title, this.lockedType});

  @override
  State<ContentListView> createState() => _ContentListViewState();
}

class _ContentListViewState extends State<ContentListView> {
  late final UploadContentController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.find<UploadContentController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.loadItems(lockedType: widget.lockedType);
    });
  }

  String get _activeRoute {
    switch (widget.lockedType) {
      case 'as':
        return AppRoutes.academicsAssignmentList;
      case 'st':
        return AppRoutes.academicsStudyMaterialList;
      case 'sy':
        return AppRoutes.academicsSyllabusList;
      case 'ot':
        return AppRoutes.academicsOtherDownloadsList;
      default:
        return AppRoutes.academicsUploadContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      body: Column(
        children: [
          AcademicsNavTabs(activeRoute: _activeRoute),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ListFilterCard(
                      controller: _c, lockedType: widget.lockedType),
                  const SizedBox(height: 16),
                  _ContentItemList(controller: _c),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter card ───────────────────────────────────────────────────────────────

class _ListFilterCard extends StatelessWidget {
  final UploadContentController controller;
  final String? lockedType;
  const _ListFilterCard(
      {required this.controller, required this.lockedType});

  UploadContentController get c => controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              aSectionHeader('Filter Content'),

              aDropdown<String>(
                value: c.filterClassId.value.isEmpty
                    ? null
                    : c.filterClassId.value,
                label: 'Class',
                items: [
                  _none('All classes'),
                  ...c.classes.map((cl) => _dd(cl.id.toString(), cl.name)),
                ],
                onChanged: (v) {
                  c.filterClassId.value = v ?? '';
                  c.filterSectionId.value = '';
                },
              ),
              const SizedBox(height: 12),

              aDropdown<String>(
                value: c.filterSectionId.value.isEmpty
                    ? null
                    : c.filterSectionId.value,
                label: 'Section',
                items: [
                  _none('All sections'),
                  ...c.filterSections
                      .map((s) => _dd(s.id.toString(), s.name)),
                ],
                onChanged: (v) => c.filterSectionId.value = v ?? '',
              ),

              // Content type only when not locked
              if (lockedType == null) ...[
                const SizedBox(height: 12),
                aDropdown<String>(
                  value: c.listContentType.value.isEmpty
                      ? null
                      : c.listContentType.value,
                  label: 'Content Type',
                  items: [
                    _none('All types'),
                    const DropdownMenuItem(
                        value: 'as', child: Text('Assignment')),
                    const DropdownMenuItem(
                        value: 'st', child: Text('Study Material')),
                    const DropdownMenuItem(
                        value: 'sy', child: Text('Syllabus')),
                    const DropdownMenuItem(
                        value: 'ot', child: Text('Other Downloads')),
                  ],
                  onChanged: (v) => c.listContentType.value = v ?? '',
                ),
              ],
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: aPrimaryBtn(
                    'Search', () => c.loadItems(lockedType: lockedType)),
              ),
            ],
          )),
    );
  }

  static DropdownMenuItem<String> _none(String label) =>
      DropdownMenuItem(
          value: '',
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF6B7280))));

  static DropdownMenuItem<String> _dd(String v, String label) =>
      DropdownMenuItem(
          value: v,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14, color: const Color(0xFF111827))));
}

// ── Content item list ─────────────────────────────────────────────────────────

class _ContentItemList extends StatelessWidget {
  final UploadContentController controller;
  const _ContentItemList({required this.controller});

  UploadContentController get c => controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          ),
        );
      }
      if (c.listError.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
          ),
          child: Text(c.listError.value,
              style: GoogleFonts.inter(
                  color: const Color(0xFFDC2626), fontSize: 14)),
        );
      }
      if (c.items.isEmpty) {
        return aEmptyState('No content found.\nAdjust filters and search.');
      }
      return Column(
        children: c.items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContentCard(item: item, controller: c),
                ))
            .toList(),
      );
    });
  }
}

// ── Content card ──────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final UploadedContent item;
  final UploadContentController controller;
  const _ContentCard({required this.item, required this.controller});

  UploadContentController get c => controller;

  Color _typeColor(String type) {
    switch (type) {
      case 'as':
        return const Color(0xFF4F46E5);
      case 'st':
        return const Color(0xFF0891B2);
      case 'sy':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              Expanded(
                child: Text(item.contentTitle,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF111827))),
              ),
              aBadge(item.contentTypeLabel, _typeColor(item.contentType)),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 20, color: Color(0xFF6B7280)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (action) {
                  if (action == 'view') _showDetails(context);
                  if (action == 'edit') _showEdit(context);
                  if (action == 'delete') _confirmDelete(context);
                },
                itemBuilder: (_) => [
                  _menuItem('view', Icons.visibility_rounded,
                      'View details', const Color(0xFF4F46E5)),
                  _menuItem('edit', Icons.edit_rounded, 'Edit',
                      const Color(0xFF0891B2)),
                  _menuItem('delete', Icons.delete_outline_rounded,
                      'Delete', const Color(0xFFDC2626)),
                ],
              ),
            ]),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Upload Date', value: item.uploadDate),
                if (item.sourceUrl.isNotEmpty)
                  _UrlRow(label: 'Source URL', url: item.sourceUrl),
                if (item.uploadFile.isNotEmpty)
                  _UrlRow(label: 'File URL', url: item.uploadFile),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description.length > 100
                        ? '${item.description.substring(0, 100)}...'
                        : item.description,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: const Color(0xFF6B7280)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label,
            style:
                GoogleFonts.inter(fontSize: 14, color: const Color(0xFF374151))),
      ]),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(item.contentTitle,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Type', item.contentTypeLabel),
              _DetailRow('Upload Date', item.uploadDate),
              _DetailRow('For Admin',
                  item.availableForAdmin ? 'Yes' : 'No'),
              _DetailRow('For All Classes',
                  item.availableForAllClasses ? 'Yes' : 'No'),
              if (item.sourceUrl.isNotEmpty)
                _DetailRow('Source URL', item.sourceUrl),
              if (item.uploadFile.isNotEmpty)
                _DetailRow('File URL', item.uploadFile),
              if (item.description.isNotEmpty)
                _DetailRow('Description', item.description),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showEdit(BuildContext context) {
    c.startEdit(item);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditSheet(controller: c, original: item),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFDC2626), size: 22),
          const SizedBox(width: 8),
          Text('Delete Content',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: Text(
            'Delete "${item.contentTitle}"? This cannot be undone.',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              c.deleteItem(item.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('Delete',
                style:
                    GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Edit bottom sheet ─────────────────────────────────────────────────────────

class _EditSheet extends StatefulWidget {
  final UploadContentController controller;
  final UploadedContent original;
  const _EditSheet({required this.controller, required this.original});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  UploadContentController get c => widget.controller;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _fileCtrl;
  late final TextEditingController _descCtrl;

  late String _contentType;
  late bool _forAdmin;
  late bool _forAllClasses;

  @override
  void initState() {
    super.initState();
    final item = widget.original;
    _titleCtrl = TextEditingController(text: item.contentTitle);
    _sourceCtrl = TextEditingController(text: item.sourceUrl);
    _fileCtrl = TextEditingController(text: item.uploadFile);
    _descCtrl = TextEditingController(text: item.description);
    _contentType = item.contentType;
    _forAdmin = item.availableForAdmin;
    _forAllClasses = item.availableForAllClasses;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _sourceCtrl.dispose();
    _fileCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: Text('Edit Content',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF6B7280))),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (ctx, setS) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        aTextField(_titleCtrl, 'Content Title *',
                            hint: 'Title'),
                        const SizedBox(height: 14),
                        aDropdown<String>(
                          value: _contentType,
                          label: 'Content Type',
                          items: const [
                            DropdownMenuItem(
                                value: 'as',
                                child: Text('Assignment')),
                            DropdownMenuItem(
                                value: 'st',
                                child: Text('Study Material')),
                            DropdownMenuItem(
                                value: 'sy', child: Text('Syllabus')),
                            DropdownMenuItem(
                                value: 'ot',
                                child: Text('Other Downloads')),
                          ],
                          onChanged: (v) =>
                              setS(() => _contentType = v ?? 'as'),
                        ),
                        const SizedBox(height: 14),
                        aTextField(_sourceCtrl, 'Source URL',
                            hint: 'https://...'),
                        const SizedBox(height: 14),
                        aTextField(_fileCtrl, 'File URL',
                            hint: 'https://...'),
                        const SizedBox(height: 14),
                        aTextField(_descCtrl, 'Description',
                            hint: 'Description...', maxLines: 3),
                        const SizedBox(height: 8),

                        CheckboxListTile(
                          value: _forAdmin,
                          onChanged: (v) =>
                              setS(() => _forAdmin = v ?? false),
                          title: Text('Available for Admin',
                              style: GoogleFonts.inter(fontSize: 14)),
                          activeColor: const Color(0xFF4F46E5),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          value: _forAllClasses,
                          onChanged: (v) =>
                              setS(() => _forAllClasses = v ?? false),
                          title: Text('Available for All Classes',
                              style: GoogleFonts.inter(fontSize: 14)),
                          activeColor: const Color(0xFF4F46E5),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 16),

                        Obx(() => Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: c.isSaving.value
                                      ? null
                                      : () async {
                                          c.editing.value = UploadedContent(
                                            id: widget.original.id,
                                            academicYearId:
                                                widget.original.academicYearId,
                                            classId: widget.original.classId,
                                            sectionId:
                                                widget.original.sectionId,
                                            contentTitle:
                                                _titleCtrl.text.trim(),
                                            contentType: _contentType,
                                            availableForAdmin: _forAdmin,
                                            availableForAllClasses:
                                                _forAllClasses,
                                            uploadDate:
                                                widget.original.uploadDate,
                                            description: _descCtrl.text.trim(),
                                            sourceUrl: _sourceCtrl.text.trim(),
                                            uploadFile: _fileCtrl.text.trim(),
                                          );
                                          await c.saveEdit();
                                          if (context.mounted &&
                                              c.listError.value.isEmpty) {
                                            Navigator.pop(context);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: c.isSaving.value
                                      ? aSavingIndicator()
                                      : Text('Update',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text('Cancel',
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ])),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF374151))),
        ),
      ]),
    );
  }
}

class _UrlRow extends StatelessWidget {
  final String label;
  final String url;
  const _UrlRow({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(
            url.length > 50 ? '${url.substring(0, 50)}...' : url,
            style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF4F46E5),
                decoration: TextDecoration.underline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 14, color: const Color(0xFF111827))),
      ]),
    );
  }
}
