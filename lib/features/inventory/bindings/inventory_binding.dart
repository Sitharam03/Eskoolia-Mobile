import 'package:get/get.dart';
import '../controllers/inventory_category_controller.dart';
import '../controllers/inventory_store_controller.dart';
import '../controllers/inventory_supplier_controller.dart';
import '../controllers/inventory_item_controller.dart';
import '../controllers/inventory_receive_controller.dart';
import '../controllers/inventory_issue_controller.dart';
import '../controllers/inventory_sell_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryCategoryController>(() => InventoryCategoryController());
    Get.lazyPut<InventoryStoreController>(() => InventoryStoreController());
    Get.lazyPut<InventorySupplierController>(() => InventorySupplierController());
    Get.lazyPut<InventoryItemController>(() => InventoryItemController());
    Get.lazyPut<InventoryReceiveController>(() => InventoryReceiveController());
    Get.lazyPut<InventoryIssueController>(() => InventoryIssueController());
    Get.lazyPut<InventorySellController>(() => InventorySellController());
  }
}
