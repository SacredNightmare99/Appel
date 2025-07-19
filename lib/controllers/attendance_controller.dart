import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/attendance.dart';
import 'package:the_project/backend/student.dart';
import 'package:the_project/controllers/student_controller.dart';
import 'package:the_project/widgets/custom_snackbar.dart';

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
          .select('uid, date, present, student_uid')
          .eq('student_uid', student.uid)
          .order('date', ascending: true);

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

  Future<void> toggleAttendanceStatus(Attendance originalAttendance, Student student) async {
    final studentController = Get.find<StudentController>();
    final updatedAttendance = originalAttendance.copyWith(present: !originalAttendance.present);
    
    try {
      await updateAttendance(originalAttendance, updatedAttendance);
      
      await fetchAttendanceForStudent(student);
      
      int presentCountChange = 0;
      if (originalAttendance.present && !updatedAttendance.present) {
        presentCountChange = -1; // Was present, now absent
      } else if (!originalAttendance.present && updatedAttendance.present) {
        presentCountChange = 1;  // Was absent, now present
      }

      if (studentController.selectedStudent.value != null) {
        studentController.selectedStudent.value = studentController.selectedStudent.value!.copyWith(
          classesPresent: studentController.selectedStudent.value!.classesPresent + presentCountChange,
        );
      }

    } catch (e) {
      CustomSnackbar.showError("Error", "Failed to update attendance status.");
    }
  }

  Future<void> deleteAttendanceRecord(Attendance attendanceToDelete, Student student) async {
    final studentController = Get.find<StudentController>();

    try {
      await deleteAttendance(attendanceToDelete);
      await fetchAttendanceForStudent(student);

      if (studentController.selectedStudent.value != null) {  
        int presentChange = attendanceToDelete.present ? -1 : 0;

        studentController.selectedStudent.value = studentController.selectedStudent.value!.copyWith(
          classes: studentController.selectedStudent.value!.classes - 1,
          classesPresent: studentController.selectedStudent.value!.classesPresent + presentChange,
        );
      }
    
    } catch (e) {
      CustomSnackbar.showError("Error", "Failed to delete attendance record.");
    }
  }

  void clear() {
    attendance.clear();
  }

}