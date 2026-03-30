import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/fees_assignment_model.dart';
import '../repositories/fees_repository.dart';

class FeesDueController extends GetxController {
  final FeesRepository _repo;
  FeesDueController(this._repo);

  final overdueList = <FeesAssignment>[].obs;
  final academicYears = <AcademicYearRef>[].obs;
  final summary = Rx<FeesSummary>(FeesSummary.empty);
  final isLoading = true.obs;
  final filterYearId = Rx<int?>(null);

  double get totalDue =>
      overdueList.fold(0.0, (sum, a) => sum + a.dueAmount);

  String yearName(int id) =>
      academicYears.firstWhereOrNull((y) => y.id == id)?.title ?? '-';

  bool isOverdue(FeesAssignment a) {
    if (a.dueDate.isEmpty) return false;
    try {
      final due = DateTime.parse(a.dueDate);
      return due.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getAcademicYears(),
        _repo.getOverdue(),
        _repo.getSummary(),
      ]);
      academicYears.assignAll(results[0] as List<AcademicYearRef>);
      overdueList.assignAll(results[1] as List<FeesAssignment>);
      summary.value = results[2] as FeesSummary;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilter() async {
    isLoading.value = true;
    try {
      final params = filterYearId.value != null
          ? {'academic_year': filterYearId.value}
          : null;
      final results = await Future.wait([
        _repo.getOverdue(params: params),
        _repo.getSummary(params: params),
      ]);
      overdueList.assignAll(results[0] as List<FeesAssignment>);
      summary.value = results[1] as FeesSummary;
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: const Color(0xFFDC2626),
          colorText: const Color(0xFFFFFFFF),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
