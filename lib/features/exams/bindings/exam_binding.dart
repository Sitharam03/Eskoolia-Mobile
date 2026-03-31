import 'package:get/get.dart';
import '../controllers/exam_type_controller.dart';
import '../controllers/exam_setup_controller.dart';
import '../controllers/exam_schedule_controller.dart';
import '../controllers/exam_marks_controller.dart';
import '../controllers/exam_marks_report_controller.dart';
import '../controllers/exam_admit_card_controller.dart';
import '../controllers/exam_attendance_controller.dart';
import '../controllers/exam_result_publish_controller.dart';
import '../controllers/exam_report_controller.dart';
import '../controllers/exam_schedule_report_controller.dart';
import '../controllers/online_exam_controller.dart';

class ExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamTypeController>(() => ExamTypeController(), fenix: true);
    Get.lazyPut<ExamSetupController>(() => ExamSetupController(), fenix: true);
    Get.lazyPut<ExamScheduleController>(() => ExamScheduleController(), fenix: true);
    Get.lazyPut<ExamMarksController>(() => ExamMarksController(), fenix: true);
    Get.lazyPut<ExamMarksReportController>(() => ExamMarksReportController(), fenix: true);
    Get.lazyPut<ExamAdmitCardController>(() => ExamAdmitCardController(), fenix: true);
    Get.lazyPut<ExamSeatPlanController>(() => ExamSeatPlanController(), fenix: true);
    Get.lazyPut<ExamAttendanceController>(() => ExamAttendanceController(), fenix: true);
    Get.lazyPut<ExamAttendanceReportController>(() => ExamAttendanceReportController(), fenix: true);
    Get.lazyPut<ExamResultPublishController>(() => ExamResultPublishController(), fenix: true);
    Get.lazyPut<ExamMeritReportController>(() => ExamMeritReportController(), fenix: true);
    Get.lazyPut<ExamStudentReportController>(() => ExamStudentReportController(), fenix: true);
    Get.lazyPut<ExamScheduleReportController>(() => ExamScheduleReportController(), fenix: true);
    Get.lazyPut<OnlineExamController>(() => OnlineExamController(), fenix: true);
  }
}
