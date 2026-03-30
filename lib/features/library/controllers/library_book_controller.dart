import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/library_models.dart';
import '../repositories/library_repository.dart';

class LibraryBookController extends GetxController {
  final _repo = LibraryRepository();

  final books = <Book>[].obs;
  final categories = <BookCategory>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMsg = ''.obs;

  // Form
  final selectedCategoryId = Rx<int?>(null);
  final titleCtrl = TextEditingController();
  final authorCtrl = TextEditingController();
  final isbnCtrl = TextEditingController();
  final publisherCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: '1');
  final availableQtyCtrl = TextEditingController(text: '1');
  final rackCtrl = TextEditingController();
  final editingId = Rx<int?>(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    authorCtrl.dispose();
    isbnCtrl.dispose();
    publisherCtrl.dispose();
    quantityCtrl.dispose();
    availableQtyCtrl.dispose();
    rackCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final results = await Future.wait([
        _repo.getBooks(),
        _repo.getCategories(activeOnly: true),
      ]);
      books.value = results[0] as List<Book>;
      categories.value = results[1] as List<BookCategory>;
    } catch (_) {
      errorMsg.value = 'Unable to load books.';
    } finally {
      isLoading.value = false;
    }
  }

  String categoryName(int? id) {
    if (id == null) return '-';
    return categories.firstWhereOrNull((c) => c.id == id)?.name ?? '-';
  }

  void startEdit(Book book) {
    editingId.value = book.id;
    selectedCategoryId.value = book.categoryId;
    titleCtrl.text = book.title;
    authorCtrl.text = book.author;
    isbnCtrl.text = book.isbn;
    publisherCtrl.text = book.publisher;
    quantityCtrl.text = book.quantity.toString();
    availableQtyCtrl.text = book.availableQuantity.toString();
    rackCtrl.text = book.rack;
    errorMsg.value = '';
  }

  void cancelEdit() {
    editingId.value = null;
    selectedCategoryId.value = null;
    titleCtrl.clear();
    authorCtrl.clear();
    isbnCtrl.clear();
    publisherCtrl.clear();
    quantityCtrl.text = '1';
    availableQtyCtrl.text = '1';
    rackCtrl.clear();
    errorMsg.value = '';
  }

  Future<void> save() async {
    final title = titleCtrl.text.trim();
    if (title.isEmpty) {
      errorMsg.value = 'Book title is required.';
      return;
    }
    final qty = int.tryParse(quantityCtrl.text.trim()) ?? -1;
    final avail = int.tryParse(availableQtyCtrl.text.trim()) ?? -1;
    if (qty < 0 || avail < 0 || avail > qty) {
      errorMsg.value = 'Quantity values are invalid.';
      return;
    }
    try {
      isSaving.value = true;
      errorMsg.value = '';
      final payload = {
        'category': selectedCategoryId.value,
        'title': title,
        'author': authorCtrl.text.trim(),
        'isbn': isbnCtrl.text.trim(),
        'publisher': publisherCtrl.text.trim(),
        'quantity': qty,
        'available_quantity': avail,
        'rack': rackCtrl.text.trim(),
      };
      if (editingId.value != null) {
        await _repo.updateBook(editingId.value!, payload);
      } else {
        await _repo.createBook(payload);
      }
      cancelEdit();
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to save book.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _repo.deleteBook(id);
      await load();
    } catch (_) {
      errorMsg.value = 'Unable to delete book.';
    }
  }
}
