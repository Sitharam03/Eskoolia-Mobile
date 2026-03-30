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
    Get.lazyPut<ExamTypeController>(() => ExamTypeController());
    Get.lazyPut<ExamSetupController>(() => ExamSetupController());
    Get.lazyPut<ExamScheduleController>(() => ExamScheduleController());
    Get.lazyPut<ExamMarksController>(() => ExamMarksController());
    Get.lazyPut<ExamMarksReportController>(() => ExamMarksReportController());
    Get.lazyPut<ExamAdmitCardController>(() => ExamAdmitCardController());
    Get.lazyPut<ExamSeatPlanController>(() => ExamSeatPlanController());
    Get.lazyPut<ExamAttendanceController>(() => ExamAttendanceController());
    Get.lazyPut<ExamAttendanceReportController>(() => ExamAttendanceReportController());
    Get.lazyPut<ExamResultPublishController>(() => ExamResultPublishController());
    Get.lazyPut<ExamMeritReportController>(() => ExamMeritReportController());
    Get.lazyPut<ExamStudentReportController>(() => ExamStudentReportController());
    Get.lazyPut<ExamScheduleReportController>(() => ExamScheduleReportController());
    Get.lazyPut<OnlineExamController>(() => OnlineExamController());
  }
}
