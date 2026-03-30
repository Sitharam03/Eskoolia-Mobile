import 'package:get/get.dart';
import '../../features/auth/bindings/login_binding.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/access_control/bindings/access_control_binding.dart';
import '../../features/access_control/views/roles_view.dart';
import '../../features/access_control/views/assign_permission_view.dart';
import '../../features/access_control/views/login_permission_view.dart';
import '../../features/access_control/views/due_fees_login_permission_view.dart';
// ── Fees ──────────────────────────────────────────────────────────────────────
import '../../features/fees/bindings/fees_binding.dart';
import '../../features/fees/views/fees_group_view.dart';
import '../../features/fees/views/fees_type_view.dart';
import '../../features/fees/views/fees_master_view.dart';
import '../../features/fees/views/fees_payment_view.dart';
import '../../features/fees/views/fees_due_view.dart';
import '../../features/fees/views/fees_carry_forward_view.dart';
import '../../features/administration/bindings/administration_binding.dart';
import '../../features/administration/views/visitor_book_view.dart';
import '../../features/administration/views/complaint_view.dart';
import '../../features/administration/views/phone_call_log_view.dart';
import '../../features/administration/views/postal_dispatch_view.dart';
import '../../features/administration/views/postal_receive_view.dart';
import '../../features/administration/views/admin_setup_view.dart';
import '../../features/administration/views/admission_query_view.dart';
import '../../features/administration/views/id_card_view.dart';
import '../../features/administration/views/certificate_view.dart';
import '../../features/administration/views/generate_id_card_view.dart';
import '../../features/administration/views/generate_certificate_view.dart';
import '../../features/students/bindings/students_binding.dart';
import '../../features/students/views/student_category_view.dart';
import '../../features/students/views/student_group_view.dart';
import '../../features/students/views/student_add_view.dart';
import '../../features/students/views/student_list_view.dart';
import '../../features/students/views/student_multi_class_view.dart';
import '../../features/students/views/student_promote_view.dart';
import '../../features/students/views/student_disabled_view.dart';
import '../../features/students/views/student_unassigned_view.dart';
import '../../features/students/views/student_delete_record_view.dart';
import '../../features/students/views/student_export_view.dart';
import '../../features/students/views/student_sms_view.dart';
import '../../features/students/views/student_attendance_import_view.dart';
import '../../features/students/views/subject_wise_attendance_view.dart';
import '../../features/students/views/subject_wise_attendance_report_view.dart';
// ── Exams ─────────────────────────────────────────────────────────────────────
import '../../features/exams/bindings/exam_binding.dart';
import '../../features/exams/views/exam_type_view.dart';
import '../../features/exams/views/exam_setup_view.dart';
import '../../features/exams/views/exam_schedule_view.dart';
import '../../features/exams/views/exam_marks_create_view.dart';
import '../../features/exams/views/exam_marks_report_view.dart';
import '../../features/exams/views/exam_admit_card_view.dart';
import '../../features/exams/views/exam_seat_plan_view.dart';
import '../../features/exams/views/exam_attendance_create_view.dart';
import '../../features/exams/views/exam_attendance_report_view.dart';
import '../../features/exams/views/exam_result_publish_view.dart';
import '../../features/exams/views/exam_merit_report_view.dart';
import '../../features/exams/views/exam_schedule_report_view.dart';
import '../../features/exams/views/exam_student_report_view.dart';
import '../../features/exams/views/online_exam_view.dart';
// ── Library ──────────────────────────────────────────────────────────────────
import '../../features/library/bindings/library_binding.dart';
import '../../features/library/views/library_category_view.dart';
import '../../features/library/views/library_book_view.dart';
import '../../features/library/views/library_member_view.dart';
import '../../features/library/views/library_issue_view.dart';
// ── Academics ────────────────────────────────────────────────────────────────
import '../../features/academics/bindings/academics_binding.dart';
import '../../features/academics/views/core_setup_view.dart';
import '../../features/academics/views/assign_class_teacher_view.dart';
import '../../features/academics/views/assign_subject_view.dart';
import '../../features/academics/views/class_room_view.dart';
import '../../features/academics/views/class_routine_view.dart';
import '../../features/academics/views/homework_add_view.dart';
import '../../features/academics/views/homework_list_view.dart';
import '../../features/academics/views/homework_evaluation_report_view.dart';
import '../../features/academics/views/upload_content_view.dart';
import '../../features/academics/views/content_list_view.dart';
import '../../features/academics/views/lesson_view.dart';
import '../../features/academics/views/topic_view.dart';
import '../../features/academics/views/lesson_planner_view.dart';
import '../routes/app_routes.dart';

/// GetX page route table.
class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
    ),
    GetPage(
      name: AppRoutes.roles,
      page: () => const RolesView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.assignPermissionRoot,
      page: () => const AssignPermissionView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.assignPermission,
      page: () => const AssignPermissionView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.loginPermission,
      page: () => const LoginPermissionView(),
      binding: AccessControlBinding(),
    ),
    GetPage(
      name: AppRoutes.dueFeesLoginPermission,
      page: () => const DueFeesLoginPermissionView(),
      binding: AccessControlBinding(),
    ),
    // ── Fees ─────────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.feesGroups, page: () => const FeesGroupView(), binding: FeesBinding()),
    GetPage(name: AppRoutes.feesTypes, page: () => const FeesTypeView(), binding: FeesBinding()),
    GetPage(name: AppRoutes.feesMaster, page: () => const FeesMasterView(), binding: FeesBinding()),
    GetPage(name: AppRoutes.feesPayments, page: () => const FeesPaymentView(), binding: FeesBinding()),
    GetPage(name: AppRoutes.feesDue, page: () => const FeesDueView(), binding: FeesBinding()),
    GetPage(name: AppRoutes.feesCarryForward, page: () => const FeesCarryForwardView(), binding: FeesBinding()),
    // ── Administration ───────────────────────────────────────────────────────
    GetPage(name: AppRoutes.adminVisitorBook, page: () => const VisitorBookView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminComplaint, page: () => const ComplaintView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminPhoneCallLog, page: () => const PhoneCallLogView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminPostalDispatch, page: () => const PostalDispatchView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminPostalReceive, page: () => const PostalReceiveView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminSetup, page: () => const AdminSetupView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminAdmissionQuery, page: () => const AdmissionQueryView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminIdCard, page: () => const IdCardView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminCertificate, page: () => const CertificateView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminGenerateIdCard, page: () => const GenerateIdCardView(), binding: AdministrationBinding()),
    GetPage(name: AppRoutes.adminGenerateCertificate, page: () => const GenerateCertificateView(), binding: AdministrationBinding()),
    // ── Students ─────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.studentCategory, page: () => const StudentCategoryView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentGroup, page: () => const StudentGroupView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentAdd, page: () => const StudentAddView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentList, page: () => const StudentListView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentMultiClass, page: () => const StudentMultiClassView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentPromote, page: () => const StudentPromoteView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentDisabled, page: () => const StudentDisabledView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentUnassigned, page: () => const StudentUnassignedView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentDeleteRecord, page: () => const StudentDeleteRecordView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentExport, page: () => const StudentExportView(), binding: StudentsBinding()),
    GetPage(name: AppRoutes.studentSms, page: () => const StudentSmsView()),
    GetPage(name: AppRoutes.studentAttendanceImport, page: () => const StudentAttendanceImportView()),
    GetPage(name: AppRoutes.studentSubjectWiseAttendance, page: () => const SubjectWiseAttendanceView()),
    GetPage(name: AppRoutes.studentSubjectWiseAttendanceReport, page: () => const SubjectWiseAttendanceReportView()),
    // ── Exams ────────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.examType, page: () => const ExamTypeView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examSetup, page: () => const ExamSetupView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examSchedule, page: () => const ExamScheduleView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examMarksCreate, page: () => const ExamMarksCreateView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examMarksRegister, page: () => const ExamMarksReportView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examAdmitCard, page: () => const ExamAdmitCardView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examSeatPlan, page: () => const ExamSeatPlanView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examAttendanceCreate, page: () => const ExamAttendanceCreateView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examAttendanceReport, page: () => const ExamAttendanceReportView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examResultPublish, page: () => const ExamResultPublishView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examMeritReport, page: () => const ExamMeritReportView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examScheduleReport, page: () => const ExamScheduleReportView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.examStudentReport, page: () => const ExamStudentReportView(), binding: ExamBinding()),
    GetPage(name: AppRoutes.onlineExam, page: () => const OnlineExamView(), binding: ExamBinding()),
    // ── Library ──────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.libraryCategories, page: () => const LibraryCategoryView(), binding: LibraryBinding()),
    GetPage(name: AppRoutes.libraryBooks, page: () => const LibraryBookView(), binding: LibraryBinding()),
    GetPage(name: AppRoutes.libraryMembers, page: () => const LibraryMemberView(), binding: LibraryBinding()),
    GetPage(name: AppRoutes.libraryIssues, page: () => const LibraryIssueView(), binding: LibraryBinding()),
    // ── Academics ────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.academicsCoreSetup, page: () => const CoreSetupView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsAssignClassTeacher, page: () => const AssignClassTeacherView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsAssignSubject, page: () => const AssignSubjectView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsClassRoom, page: () => const ClassRoomView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsClassRoutine, page: () => const ClassRoutineView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsHomeworkAdd, page: () => const HomeworkAddView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsHomeworkList, page: () => const HomeworkListView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsHomeworkEvalReport, page: () => const HomeworkEvaluationReportView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsUploadContent, page: () => const UploadContentView(), binding: AcademicsBinding()),
    GetPage(
      name: AppRoutes.academicsAssignmentList,
      page: () => ContentListView(title: 'Assignment List', lockedType: 'as'),
      binding: AcademicsBinding(),
    ),
    GetPage(
      name: AppRoutes.academicsStudyMaterialList,
      page: () => ContentListView(title: 'Study Material List', lockedType: 'st'),
      binding: AcademicsBinding(),
    ),
    GetPage(
      name: AppRoutes.academicsSyllabusList,
      page: () => ContentListView(title: 'Syllabus List', lockedType: 'sy'),
      binding: AcademicsBinding(),
    ),
    GetPage(
      name: AppRoutes.academicsOtherDownloadsList,
      page: () => ContentListView(title: 'Other Downloads', lockedType: 'ot'),
      binding: AcademicsBinding(),
    ),
    GetPage(name: AppRoutes.academicsLessons, page: () => const LessonView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsTopics, page: () => const TopicView(), binding: AcademicsBinding()),
    GetPage(name: AppRoutes.academicsLessonPlanner, page: () => const LessonPlannerView(), binding: AcademicsBinding()),
  ];
}
