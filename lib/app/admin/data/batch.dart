import 'package:the_project/app/admin/data/student.dart';

class Batch {
  final String name;
  final String timing;
  final List<Student> students;
  bool marked;

  Batch({
    required this.name,
    required this.timing,
    required this.students,
    this.marked = false
  });

  int get studentCount => students.length;
}