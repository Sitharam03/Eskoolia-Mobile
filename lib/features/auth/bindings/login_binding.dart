import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// Lazily injects [LoginController] when the login route is pushed.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
