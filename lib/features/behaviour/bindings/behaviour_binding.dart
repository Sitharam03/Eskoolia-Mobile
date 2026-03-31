import 'package:get/get.dart';

import '../controllers/behaviour_incident_controller.dart';
import '../controllers/behaviour_assignment_controller.dart';
import '../controllers/behaviour_settings_controller.dart';
import '../repositories/behaviour_repository.dart';

class BehaviourBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BehaviourRepository>(
      () => BehaviourRepository(),
      fenix: true,
    );
    Get.lazyPut<BehaviourIncidentController>(
      () => BehaviourIncidentController(Get.find()),
      fenix: true,
    );
    Get.lazyPut<BehaviourAssignmentController>(
      () => BehaviourAssignmentController(Get.find()),
      fenix: true,
    );
    Get.lazyPut<BehaviourSettingsController>(
      () => BehaviourSettingsController(Get.find()),
      fenix: true,
    );
  }
}
