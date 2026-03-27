import 'package:get/get.dart';
import '../controllers/administration_controller.dart';
import '../repositories/administration_repository.dart';

class AdministrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdministrationController>(
      () => AdministrationController(repository: AdministrationRepository()),
      fenix: true,
    );
  }
}
