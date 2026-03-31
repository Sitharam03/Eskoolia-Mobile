import '../../../core/network/api_client.dart';
import '../models/inventory_models.dart';

List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) {
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  if (data is Map && data['results'] is List) {
    return (data['results'] as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

class InventoryRepository {
  // ── Item Categories ──────────────────────────────────────────────────────────

  Future<List<ItemCategory>> getCategories() async {
    final res = await ApiClient.dio.get('/api/v1/core/item-categories/');
    return _parseList(res.data, ItemCategory.fromJson);
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/item-categories/', data: data);
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/core/item-categories/$id/', data: data);
  }

  Future<void> deleteCategory(int id) async {
    await ApiClient.dio.delete('/api/v1/core/item-categories/$id/');
  }

  // ── Item Stores ───────────────────────────────────────────────────────────

  Future<List<ItemStore>> getStores() async {
    final res = await ApiClient.dio.get('/api/v1/core/item-stores/');
    return _parseList(res.data, ItemStore.fromJson);
  }

  Future<void> createStore(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/item-stores/', data: data);
  }

  Future<void> updateStore(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/core/item-stores/$id/', data: data);
  }

  Future<void> deleteStore(int id) async {
    await ApiClient.dio.delete('/api/v1/core/item-stores/$id/');
  }

  // ── Suppliers ────────────────────────────────────────────────────────────

  Future<List<Supplier>> getSuppliers() async {
    final res = await ApiClient.dio.get('/api/v1/core/suppliers/');
    return _parseList(res.data, Supplier.fromJson);
  }

  Future<void> createSupplier(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/suppliers/', data: data);
  }

  Future<void> updateSupplier(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/core/suppliers/$id/', data: data);
  }

  Future<void> deleteSupplier(int id) async {
    await ApiClient.dio.delete('/api/v1/core/suppliers/$id/');
  }

  // ── Items ────────────────────────────────────────────────────────────────

  Future<List<InventoryItem>> getItems() async {
    final res = await ApiClient.dio.get('/api/v1/core/items/');
    return _parseList(res.data, InventoryItem.fromJson);
  }

  Future<void> createItem(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/items/', data: data);
  }

  Future<void> updateItem(int id, Map<String, dynamic> data) async {
    await ApiClient.dio.patch('/api/v1/core/items/$id/', data: data);
  }

  Future<void> deleteItem(int id) async {
    await ApiClient.dio.delete('/api/v1/core/items/$id/');
  }

  // ── Item Receives ────────────────────────────────────────────────────────

  Future<List<ItemReceive>> getReceives() async {
    final res = await ApiClient.dio.get('/api/v1/core/item-receives/');
    return _parseList(res.data, ItemReceive.fromJson);
  }

  Future<void> createReceive(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/item-receives/', data: data);
  }

  Future<void> deleteReceive(int id) async {
    await ApiClient.dio.delete('/api/v1/core/item-receives/$id/');
  }

  // ── Item Issues ──────────────────────────────────────────────────────────

  Future<List<ItemIssue>> getIssues() async {
    final res = await ApiClient.dio.get('/api/v1/core/item-issues/');
    return _parseList(res.data, ItemIssue.fromJson);
  }

  Future<void> createIssue(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/item-issues/', data: data);
  }

  Future<void> deleteIssue(int id) async {
    await ApiClient.dio.delete('/api/v1/core/item-issues/$id/');
  }

  // ── Item Sells ───────────────────────────────────────────────────────────

  Future<List<ItemSell>> getSells() async {
    final res = await ApiClient.dio.get('/api/v1/core/item-sells/');
    return _parseList(res.data, ItemSell.fromJson);
  }

  Future<void> createSell(Map<String, dynamic> data) async {
    await ApiClient.dio.post('/api/v1/core/item-sells/', data: data);
  }

  Future<void> deleteSell(int id) async {
    await ApiClient.dio.delete('/api/v1/core/item-sells/$id/');
  }
}
