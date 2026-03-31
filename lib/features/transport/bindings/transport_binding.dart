import 'package:get/get.dart';
import '../controllers/transport_route_controller.dart';
import '../controllers/transport_vehicle_controller.dart';
import '../controllers/transport_assign_controller.dart';
import '../controllers/transport_student_report_controller.dart';

class TransportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransportRouteController>(() => TransportRouteController());
    Get.lazyPut<TransportVehicleController>(() => TransportVehicleController());
    Get.lazyPut<TransportAssignController>(() => TransportAssignController());
    Get.lazyPut<TransportStudentReportController>(
        () => TransportStudentReportController());
  }
}
