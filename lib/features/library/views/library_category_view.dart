import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/library_category_controller.dart';
import '../models/library_models.dart';
import '_library_nav_tabs.dart';

class LibraryCategoryView extends StatelessWidget {
  const LibraryCategoryView({super.key});

  LibraryCategoryController get _c =>
      Get.find<LibraryCategoryController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Library',
      body: Column(
        children: [
          const LibraryNavTabs(activeRoute: AppRoutes.libraryCategories),
          Expanded(
            child: Obx(() {
              if (_c.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4F46E5)));
              }
              return RefreshIndicator(
                color: const Color(0xFF4F46E5),
                onRefresh: _c.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    children: [
                      _FormCard(c: _c),
                      Obx(() {
                        if (_c.errorMsg.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _ErrorBanner(msg: _c.errorMsg.value),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      const SizedBox(height: 16),
                      _CategoryList(c: _c),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final LibraryCategoryController c;
  const _FormCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: sCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sectionHeader(c.editingId.value != null
                      ? 'Edit Category'
                      : 'Add Category'),
                  if (c.editingId.value != null)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF6B7280), size: 20),
                      onPressed: c.cancelEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              sFieldLabel('Category Name *'),
              const SizedBox(height: 6),
              sTextField(controller: c.nameCtrl, hint: 'Enter category name'),
              const SizedBox(height: 12),
              sFieldLabel('Description'),
              const SizedBox(height: 6),
              sTextField(
                  controller: c.descCtrl,
                  hint: 'Optional description',
                  maxLines: 2),
              const SizedBox(height: 12),
              Row(children: [
                Obx(() => Checkbox(
                      value: c.isActive.value,
                      onChanged: (v) => c.isActive.value = v ?? true,
                      activeColor: const Color(0xFF4F46E5),
                    )),
                Text('Active',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF374151))),
              ]),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: c.isSaving.value ? null : c.save,
                  icon: c.isSaving.value
                      ? sSavingIndicator()
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                      c.isSaving.value
                          ? 'Saving…'
                          : (c.editingId.value != null ? 'Update' : 'Save'),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final LibraryCategoryController c;
  const _CategoryList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.categories.isEmpty) {
        return sEmptyState(
            'No categories yet', Icons.category_outlined);
      }
      return Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            sectionHeader('Categories'),
            Text('${c.categories.length} total',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF6B7280))),
          ]),
          const SizedBox(height: 12),
          ...c.categories.map((cat) => _CategoryRow(cat: cat, c: c)),
        ]),
      );
    });
  }
}

class _CategoryRow extends StatelessWidget {
  final BookCategory cat;
  final LibraryCategoryController c;
  const _CategoryRow({required this.cat, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cat.name,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827))),
            if (cat.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(cat.description,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF6B7280))),
            ],
          ]),
        ),
        sBadge(cat.isActive ? 'Active' : 'Inactive',
            cat.isActive ? const Color(0xFF059669) : const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        sIconBtn(Icons.edit_rounded, const Color(0xFF0EA5E9),
            () => c.startEdit(cat)),
        sIconBtn(Icons.delete_outline_rounded, const Color(0xFFDC2626), () {
          showDialog(
            context: context,
            builder: (_) => sDeleteDialog(
              context: context,
              message: 'Delete category "${cat.name}"?',
              onConfirm: () => c.delete(cat.id),
            ),
          );
        }),
      ]),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String msg;
  const _ErrorBanner({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.08),
        border:
            Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            color: Color(0xFFDC2626), size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFFDC2626)))),
      ]),
    );
  }
}
