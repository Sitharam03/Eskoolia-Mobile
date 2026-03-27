import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/student_category_controller.dart';
import '../models/student_category_model.dart';
import '_student_nav_tabs.dart';
import '_student_shared.dart';

class StudentCategoryView extends StatefulWidget {
  const StudentCategoryView({super.key});
  @override
  State<StudentCategoryView> createState() => _StudentCategoryViewState();
}

class _StudentCategoryViewState extends State<StudentCategoryView> {
  StudentCategoryController get _c => Get.find<StudentCategoryController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Student Categories',
      body: Column(children: [
        const StudentNavTabs(activeRoute: AppRoutes.studentCategory),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildForm(),
                const SizedBox(height: 20),
                _buildList(),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildForm() {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Obx(() => sectionHeader(
            _c.editingId.value != null ? 'Edit Category' : 'Add Category')),
        const SizedBox(height: 16),
        sFieldLabel('Category Name *'),
        const SizedBox(height: 6),
        sTextField(controller: _c.nameCtrl, hint: 'e.g. General, SC, ST, OBC'),
        const SizedBox(height: 14),
        sFieldLabel('Description'),
        const SizedBox(height: 6),
        sTextField(
          controller: _c.descriptionCtrl,
          hint: 'Optional description',
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        Obx(() => Row(children: [
              if (_c.editingId.value != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _c.resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Cancel',
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _c.isSaving.value ? null : _c.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _c.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _c.editingId.value != null
                              ? 'Update Category'
                              : 'Save Category',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ])),
      ]),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (_c.isLoading.value) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: sectionHeader('All Categories (${_c.filtered.length})')),
          sRefreshButton(_c.loadCategories),
        ]),
        const SizedBox(height: 12),
        sSearchBar(
            hint: 'Search categories...',
            onChanged: (v) => _c.searchQuery.value = v),
        const SizedBox(height: 12),
        if (_c.filtered.isEmpty)
          sEmptyState('No categories found.\nAdd your first category above.',
              Icons.label_outline_rounded)
        else
          ...List.generate(_c.filtered.length, (i) {
            final cat = _c.filtered[i];
            return _CategoryCard(
              cat: cat,
              onEdit: () => _c.startEdit(cat),
              onDelete: () => _confirmDelete(cat),
            );
          }),
      ]);
    });
  }

  void _confirmDelete(StudentCategory cat) {
    showDialog(
      context: context,
      builder: (_) => sDeleteDialog(
        context: context,
        message: 'Delete category "${cat.name}"? This cannot be undone.',
        onConfirm: () => _c.delete(cat.id),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final StudentCategory cat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.cat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: sCardDecoration,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.label_rounded,
              color: Color(0xFF4F46E5), size: 20),
        ),
        title: Text(
          cat.name,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF111827)),
        ),
        subtitle: cat.description.isNotEmpty
            ? Text(cat.description,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF6B7280)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          sIconBtn(Icons.edit_outlined, const Color(0xFF4F46E5), onEdit),
          sIconBtn(Icons.delete_outline_rounded, const Color(0xFFDC2626), onDelete),
        ]),
      ),
    );
  }
}
