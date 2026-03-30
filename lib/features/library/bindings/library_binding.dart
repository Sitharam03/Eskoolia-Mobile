import 'package:get/get.dart';
import '../controllers/library_category_controller.dart';
import '../controllers/library_book_controller.dart';
import '../controllers/library_member_controller.dart';
import '../controllers/library_issue_controller.dart';

class LibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LibraryCategoryController>(() => LibraryCategoryController());
    Get.lazyPut<LibraryBookController>(() => LibraryBookController());
    Get.lazyPut<LibraryMemberController>(() => LibraryMemberController());
    Get.lazyPut<LibraryIssueController>(() => LibraryIssueController());
  }
}
