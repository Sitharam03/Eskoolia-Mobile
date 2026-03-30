import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../students/views/_student_shared.dart';
import '../controllers/library_book_controller.dart';
import '../models/library_models.dart';
import '_library_nav_tabs.dart';

class LibraryBookView extends StatelessWidget {
  const LibraryBookView({super.key});

  LibraryBookController get _c => Get.find<LibraryBookController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Library',
      body: Column(
        children: [
          const LibraryNavTabs(activeRoute: AppRoutes.libraryBooks),
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
                      _BookList(c: _c),
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
  final LibraryBookController c;
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
                      ? 'Edit Book'
                      : 'Add Book'),
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
              sFieldLabel('Category'),
              const SizedBox(height: 6),
              sDropdown<int>(
                value: c.selectedCategoryId.value,
                hint: 'Select Category',
                items: c.categories
                    .map((cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (v) => c.selectedCategoryId.value = v,
              ),
              const SizedBox(height: 12),
              sFieldLabel('Title *'),
              const SizedBox(height: 6),
              sTextField(controller: c.titleCtrl, hint: 'Book title'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Author'),
                        const SizedBox(height: 6),
                        sTextField(controller: c.authorCtrl, hint: 'Author name'),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('ISBN'),
                        const SizedBox(height: 6),
                        sTextField(controller: c.isbnCtrl, hint: 'ISBN number'),
                      ]),
                ),
              ]),
              const SizedBox(height: 12),
              sFieldLabel('Publisher'),
              const SizedBox(height: 6),
              sTextField(controller: c.publisherCtrl, hint: 'Publisher name'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Total Qty'),
                        const SizedBox(height: 6),
                        sTextField(
                            controller: c.quantityCtrl,
                            hint: '1',
                            keyboardType: TextInputType.number),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Available Qty'),
                        const SizedBox(height: 6),
                        sTextField(
                            controller: c.availableQtyCtrl,
                            hint: '1',
                            keyboardType: TextInputType.number),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sFieldLabel('Rack'),
                        const SizedBox(height: 6),
                        sTextField(controller: c.rackCtrl, hint: 'A-1'),
                      ]),
                ),
              ]),
              const SizedBox(height: 16),
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

class _BookList extends StatelessWidget {
  final LibraryBookController c;
  const _BookList({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.books.isEmpty) {
        return sEmptyState('No books yet', Icons.menu_book_rounded);
      }
      return Container(
        decoration: sCardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            sectionHeader('Books'),
            Text('${c.books.length} total',
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF6B7280))),
          ]),
          const SizedBox(height: 12),
          ...c.books.map((book) => _BookRow(book: book, c: c)),
        ]),
      );
    });
  }
}

class _BookRow extends StatelessWidget {
  final Book book;
  final LibraryBookController c;
  const _BookRow({required this.book, required this.c});

  @override
  Widget build(BuildContext context) {
    final isLow = book.availableQuantity == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(book.title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
          ),
          sBadge(
            book.availabilityLabel,
            isLow ? const Color(0xFFDC2626) : const Color(0xFF059669),
          ),
        ]),
        const SizedBox(height: 4),
        Wrap(spacing: 12, runSpacing: 2, children: [
          if (book.author.isNotEmpty)
            _Detail(Icons.person_outline_rounded, book.author),
          _Detail(Icons.category_outlined, c.categoryName(book.categoryId)),
          if (book.isbn.isNotEmpty)
            _Detail(Icons.tag_rounded, 'ISBN: ${book.isbn}'),
          if (book.rack.isNotEmpty)
            _Detail(Icons.shelves, 'Rack: ${book.rack}'),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          sIconBtn(Icons.edit_rounded, const Color(0xFF0EA5E9),
              () => c.startEdit(book)),
          sIconBtn(Icons.delete_outline_rounded, const Color(0xFFDC2626),
              () {
            showDialog(
              context: context,
              builder: (_) => sDeleteDialog(
                context: context,
                message: 'Delete "${book.title}"?',
                onConfirm: () => c.delete(book.id),
              ),
            );
          }),
        ]),
      ]),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Detail(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
      const SizedBox(width: 4),
      Text(text,
          style: GoogleFonts.inter(
              fontSize: 12, color: const Color(0xFF6B7280))),
    ]);
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
