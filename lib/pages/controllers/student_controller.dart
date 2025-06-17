import 'package:get/get.dart';
import 'package:the_project/backend/student.dart';

class StudentController extends GetxController {
  final Rxn<Student> selectedStudent = Rxn<Student>();

  void selectStudent(Student student) {
    selectedStudent.value = student;
  }
}