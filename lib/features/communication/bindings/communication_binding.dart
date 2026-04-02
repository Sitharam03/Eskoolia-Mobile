import 'package:get/get.dart';

import '../controllers/communication_controller.dart';
import '../repositories/communication_repository.dart';

class CommunicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunicationRepository>(
      () => CommunicationRepository(),
      fenix: true,
    );
    Get.lazyPut<CommunicationController>(
      () => CommunicationController(Get.find()),
      fenix: true,
    );
  }
}
