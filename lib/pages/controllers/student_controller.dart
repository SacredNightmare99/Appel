import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/student.dart';

class StudentController extends GetxController {
  final Rxn<Student> selectedStudent = Rxn<Student>();
  var allStudents = <Student>[].obs;
  var batchStudentMap = <String, RxList<Student>>{}.obs;
  var isLoading = false.obs;
  var isBatchLoading = false.obs;
  var filteredStudents = <Student>[].obs;

  void selectStudent(Student student) {
    selectedStudent.value = student;
  }

  Future<void> refreshAllStudents() async {
    isLoading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('students').select().order('name', ascending: true);

      allStudents.value = (data as List)
          .map((item) => Student.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching students: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBatchStudents(String batchUid) async {
    isBatchLoading.value = true;

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('students')
          .select()
          .eq('batch_id', batchUid)
          .order('name', ascending: true);

      final students = (data as List)
          .map((item) => Student.fromMap(item))
          .toList();
      batchStudentMap[batchUid] = students.obs;
    } catch (e) {
      debugPrint('Error fetching batch students: $e');
    } finally {
      isBatchLoading.value = false;
    }
  }

  List<Student> getBatchStudents(String batchUid) {
    return batchStudentMap[batchUid]?.toList() ?? [];
  }

  void filterStudentsByName(String query) {
    if (query.isEmpty) {
      filteredStudents.assignAll(allStudents);
    } else {
      filteredStudents.assignAll(
        allStudents.where((student) => student.name.toLowerCase().contains(query.toLowerCase()))
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    refreshAllStudents();
    ever(allStudents, (_) => filteredStudents.assignAll(allStudents));
  }

}