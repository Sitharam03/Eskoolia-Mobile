import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Item Category ─────────────────────────────────────────────────────────────

class ItemCategory {
  final int id;
  final String title;
  final String description;
  final bool isActive;

  const ItemCategory({required this.id, required this.title, required this.description, required this.isActive});

  factory ItemCategory.fromJson(Map<String, dynamic> j) => ItemCategory(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        isActive: j['is_active'] == true,
      );
}

// ── Item Store ────────────────────────────────────────────────────────────────

class ItemStore {
  final int id;
  final String title;
  final String location;
  final String description;

  const ItemStore({required this.id, required this.title, required this.location, required this.description});

  factory ItemStore.fromJson(Map<String, dynamic> j) => ItemStore(
        id: j['id'] as int,
        title: j['title'] as String? ?? '',
        location: j['location'] as String? ?? '',
        description: j['description'] as String? ?? '',
      );
}

// ── Supplier ──────────────────────────────────────────────────────────────────

class Supplier {
  final int id;
  final String name;
  final String contact;
  final String email;
  final String phone;
  final String address;
  final String taxId;
  final String paymentTerms;

  const Supplier({
    required this.id, required this.name, required this.contact,
    required this.email, required this.phone, required this.address,
    required this.taxId, required this.paymentTerms,
  });

  factory Supplier.fromJson(Map<String, dynamic> j) => Supplier(
        id: j['id'] as int,
        name: j['name'] as String? ?? '',
        contact: j['contact'] as String? ?? '',
        email: j['email'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        address: j['address'] as String? ?? '',
        taxId: j['tax_id'] as String? ?? '',
        paymentTerms: j['payment_terms'] as String? ?? 'NET30',
      );
}

// ── Inventory Item ────────────────────────────────────────────────────────────

class InventoryItem {
  final int id;
  final String itemCode;
  final String name;
  final double quantity;
  final String unit;
  final double reorderLevel;
  final double unitCost;
  final double unitPrice;
  final int? categoryId;
  final String categoryTitle;
  final int? supplierId;
  final String supplierName;

  const InventoryItem({
    required this.id, required this.itemCode, required this.name,
    required this.quantity, required this.unit, required this.reorderLevel,
    required this.unitCost, required this.unitPrice,
    this.categoryId, required this.categoryTitle,
    this.supplierId, required this.supplierName,
  });

  bool get isLowStock => quantity <= reorderLevel;

  factory InventoryItem.fromJson(Map<String, dynamic> j) {
    int? categoryId;
    String categoryTitle = '';
    final catData = j['category'] ?? j['category_id'];
    if (catData is int) {
      categoryId = catData;
      categoryTitle = j['category_title'] as String? ?? '';
    } else if (catData is Map<String, dynamic>) {
      categoryId = catData['id'] as int?;
      categoryTitle = catData['title'] as String? ?? '';
    }
    if (categoryTitle.isEmpty) categoryTitle = j['category_title'] as String? ?? '';

    int? supplierId;
    String supplierName = '';
    final supData = j['supplier'] ?? j['supplier_id'];
    if (supData is int) {
      supplierId = supData;
      supplierName = j['supplier_name'] as String? ?? '';
    } else if (supData is Map<String, dynamic>) {
      supplierId = supData['id'] as int?;
      supplierName = supData['name'] as String? ?? '';
    }
    if (supplierName.isEmpty) supplierName = j['supplier_name'] as String? ?? '';

    return InventoryItem(
      id: j['id'] as int,
      itemCode: j['item_code'] as String? ?? '',
      name: j['name'] as String? ?? '',
      quantity: _toDouble(j['quantity']),
      unit: j['unit'] as String? ?? 'piece',
      reorderLevel: _toDouble(j['reorder_level']),
      unitCost: _toDouble(j['unit_cost']),
      unitPrice: _toDouble(j['unit_price']),
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      supplierId: supplierId,
      supplierName: supplierName,
    );
  }
}

// ── Item Receive ──────────────────────────────────────────────────────────────

class ItemReceive {
  final int id;
  final int? supplierId;
  final String supplierName;
  final String receiveDate;
  final double totalAmount;
  final double discount;
  final double tax;
  final double paidAmount;
  final String paymentStatus; // 'U' | 'PP' | 'P'
  final String notes;
  final String createdByName;

  const ItemReceive({
    required this.id, this.supplierId, required this.supplierName,
    required this.receiveDate, required this.totalAmount, required this.discount,
    required this.tax, required this.paidAmount, required this.paymentStatus,
    required this.notes, required this.createdByName,
  });

  double get total => totalAmount;

  String get paymentLabel {
    switch (paymentStatus) {
      case 'P': return 'Paid';
      case 'PP': return 'Partial';
      default: return 'Unpaid';
    }
  }

  factory ItemReceive.fromJson(Map<String, dynamic> j) {
    int? supplierId;
    String supplierName = '';
    final supData = j['supplier'];
    if (supData is int) {
      supplierId = supData;
      supplierName = j['supplier_name'] as String? ?? '';
    } else if (supData is Map<String, dynamic>) {
      supplierId = supData['id'] as int?;
      supplierName = supData['name'] as String? ?? '';
    }
    if (supplierName.isEmpty) supplierName = j['supplier_name'] as String? ?? '';

    return ItemReceive(
      id: j['id'] as int,
      supplierId: supplierId,
      supplierName: supplierName,
      receiveDate: j['receive_date'] as String? ?? '',
      totalAmount: _toDouble(j['total_amount'] ?? j['total']),
      discount: _toDouble(j['discount']),
      tax: _toDouble(j['tax']),
      paidAmount: _toDouble(j['paid_amount']),
      paymentStatus: j['payment_status'] as String? ?? 'U',
      notes: j['notes'] as String? ?? '',
      createdByName: j['created_by_name'] as String? ?? '',
    );
  }
}

// ── Item Issue ────────────────────────────────────────────────────────────────

class ItemIssue {
  final int id;
  final int? storeId;
  final String storeTitle;
  final int? itemId;
  final String itemName;
  final double quantity;
  final String subject;
  final String notes;
  final String issuedByName;
  final String createdAt;

  const ItemIssue({
    required this.id, this.storeId, required this.storeTitle,
    this.itemId, required this.itemName, required this.quantity,
    required this.subject, required this.notes,
    required this.issuedByName, required this.createdAt,
  });

  factory ItemIssue.fromJson(Map<String, dynamic> j) {
    int? storeId;
    String storeTitle = '';
    final stData = j['store'];
    if (stData is int) { storeId = stData; storeTitle = j['store_title'] as String? ?? ''; }
    else if (stData is Map<String, dynamic>) { storeId = stData['id'] as int?; storeTitle = stData['title'] as String? ?? ''; }
    if (storeTitle.isEmpty) storeTitle = j['store_title'] as String? ?? '';

    int? itemId;
    String itemName = '';
    final itData = j['item'];
    if (itData is int) { itemId = itData; itemName = j['item_name'] as String? ?? ''; }
    else if (itData is Map<String, dynamic>) { itemId = itData['id'] as int?; itemName = itData['name'] as String? ?? ''; }
    if (itemName.isEmpty) itemName = j['item_name'] as String? ?? '';

    return ItemIssue(
      id: j['id'] as int,
      storeId: storeId, storeTitle: storeTitle,
      itemId: itemId, itemName: itemName,
      quantity: _toDouble(j['quantity']),
      subject: j['subject'] as String? ?? '',
      notes: j['notes'] as String? ?? '',
      issuedByName: j['issued_by_name'] as String? ?? '',
      createdAt: j['created_at'] as String? ?? '',
    );
  }
}

// ── Item Sell ─────────────────────────────────────────────────────────────────

class ItemSell {
  final int id;
  final String sellDate;
  final String soldTo;
  final double totalAmount;
  final double discount;
  final double tax;
  final double paidAmount;
  final String paymentStatus;
  final String notes;
  final String createdByName;

  const ItemSell({
    required this.id, required this.sellDate, required this.soldTo,
    required this.totalAmount, required this.discount, required this.tax,
    required this.paidAmount, required this.paymentStatus,
    required this.notes, required this.createdByName,
  });

  double get total => totalAmount;

  String get paymentLabel {
    switch (paymentStatus) {
      case 'P': return 'Paid';
      case 'PP': return 'Partial';
      default: return 'Unpaid';
    }
  }

  factory ItemSell.fromJson(Map<String, dynamic> j) => ItemSell(
        id: j['id'] as int,
        sellDate: j['sell_date'] as String? ?? '',
        soldTo: j['sold_to'] as String? ?? '',
        totalAmount: _toDouble(j['total_amount'] ?? j['total']),
        discount: _toDouble(j['discount']),
        tax: _toDouble(j['tax']),
        paidAmount: _toDouble(j['paid_amount']),
        paymentStatus: j['payment_status'] as String? ?? 'U',
        notes: j['notes'] as String? ?? '',
        createdByName: j['created_by_name'] as String? ?? '',
      );
}

// ── Line Item Forms (form state, not API models) ───────────────────────────────

class ReceiveLineItemForm {
  final selectedItemId = Rx<int?>(null);
  final qtyCtrl = TextEditingController(text: '1');
  final costCtrl = TextEditingController(text: '0.00');

  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
  }

  Map<String, dynamic> toJson() => {
        'item': selectedItemId.value,
        'quantity': double.tryParse(qtyCtrl.text) ?? 0,
        'unit_cost': double.tryParse(costCtrl.text) ?? 0,
      };
}

class SellLineItemForm {
  final selectedItemId = Rx<int?>(null);
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController(text: '0.00');

  void dispose() {
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }

  Map<String, dynamic> toJson() => {
        'item': selectedItemId.value,
        'quantity': double.tryParse(qtyCtrl.text) ?? 0,
        'unit_price': double.tryParse(priceCtrl.text) ?? 0,
      };
}

// ── Helpers ───────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
