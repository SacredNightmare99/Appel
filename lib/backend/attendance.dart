import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/student.dart';

class Attendance {
  final DateTime date;
  final bool present;
  final String studentUid;

  const Attendance({required this.date, this.present = false, required this.studentUid});

  factory Attendance.fromMap(Map<String, dynamic> map) => Attendance(
        date: DateTime.parse(map['date']),
        present: map['present'],
        studentUid: map['student_uid'],
      ); 
}

Stream<List<Attendance>> streamAttendanceForStudent(Student student) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('attendance')
      .stream(primaryKey: ['uid'])
      .eq('student_uid', student.uid)
      .map((data) => data
          .map((item) => Attendance.fromMap(item))
          .toList());
}