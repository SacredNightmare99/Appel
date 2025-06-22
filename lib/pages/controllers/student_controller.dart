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

  void selectStudent(Student student) {
    selectedStudent.value = student;
  }

  Future<void> refreshAllStudents() async {
    isLoading.value = true;
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('students').select();

      allStudents.value = (data as List)
          .map((item) => Student.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching students: $e');
      allStudents.clear(); // or keep previous data if needed
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
          .eq('batch_id', batchUid);

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

  @override
  void onInit() {
    super.onInit();
    refreshAllStudents();
  }

}