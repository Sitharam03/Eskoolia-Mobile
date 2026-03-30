import 'package:get/get.dart';
import '../controllers/core_setup_controller.dart';
import '../controllers/assign_class_teacher_controller.dart';
import '../controllers/assign_subject_controller.dart';
import '../controllers/class_room_controller.dart';
import '../controllers/class_routine_controller.dart';
import '../controllers/homework_controller.dart';
import '../controllers/upload_content_controller.dart';
import '../controllers/lesson_controller.dart';
import '../controllers/topic_controller.dart';
import '../controllers/lesson_planner_controller.dart';
import '../repositories/academics_repository.dart';

class AcademicsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AcademicsRepository());
    Get.lazyPut(() => CoreSetupController());
    Get.lazyPut(() => AssignClassTeacherController());
    Get.lazyPut(() => AssignSubjectController());
    Get.lazyPut(() => ClassRoomController());
    Get.lazyPut(() => ClassRoutineController());
    Get.lazyPut(() => HomeworkController());
    Get.lazyPut(() => UploadContentController());
    Get.lazyPut(() => LessonController());
    Get.lazyPut(() => TopicController());
    Get.lazyPut(() => LessonPlannerController());
  }
}
