import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/attendance.dart';
import 'package:the_project/backend/student.dart';

class AttendanceController extends GetxController {
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxBool isDayWise = false.obs;
  final Rxn<DateTime> refreshTrigger = Rxn<DateTime>();

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void toggleDayWise() {
    isDayWise.value = !isDayWise.value;
  }

  void setDayWise(bool value) {
    isDayWise.value = value;
  }

  void triggerRefresh() {
    refreshTrigger.value = DateTime.now();
  }


  var attendance = <Attendance>[].obs;
  var isLoading = false.obs;

  Future<void> fetchAttendanceForStudent(Student student) async {
    isLoading.value = true;

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('attendance')
          .select()
          .eq('student_uid', student.uid)
          .order('date');

      attendance.value = (data as List)
          .map((item) => Attendance.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      attendance.clear();
    } finally {
      isLoading.value = false;
    }

  }

  void clear() {
    attendance.clear();
  }

}