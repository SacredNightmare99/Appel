import 'package:the_project/pages/admin/data/student.dart';

class Batch {
  final String name;
  final String timing;
  final List<Student> students;

  Batch({
    required this.name,
    required this.timing,
    required this.students
  });

  int get studentCount => students.length;
}