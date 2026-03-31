import 'package:get/get.dart';

import '../controllers/fees_carry_forward_controller.dart';
import '../controllers/fees_due_controller.dart';
import '../controllers/fees_group_controller.dart';
import '../controllers/fees_master_controller.dart';
import '../controllers/fees_payment_controller.dart';
import '../controllers/fees_type_controller.dart';
import '../repositories/fees_repository.dart';

class FeesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeesRepository>(() => FeesRepository(), fenix: true);
    Get.lazyPut<FeesGroupController>(
        () => FeesGroupController(Get.find<FeesRepository>()),
        fenix: true);
    Get.lazyPut<FeesTypeController>(
        () => FeesTypeController(Get.find<FeesRepository>()),
        fenix: true);
    Get.lazyPut<FeesMasterController>(
        () => FeesMasterController(Get.find<FeesRepository>()),
        fenix: true);
    Get.lazyPut<FeesPaymentController>(
        () => FeesPaymentController(Get.find<FeesRepository>()),
        fenix: true);
    Get.lazyPut<FeesDueController>(
        () => FeesDueController(Get.find<FeesRepository>()),
        fenix: true);
    Get.lazyPut<FeesCarryForwardController>(
        () => FeesCarryForwardController(Get.find<FeesRepository>()),
        fenix: true);
  }
}
