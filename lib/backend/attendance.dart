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


Future<void> markAttendanceForStudent(Student student, bool present, DateTime date) async {
  final supabase = Supabase.instance.client;

  final dateOnly = DateTime(date.year, date.month, date.day);

  await supabase.from('attendance').insert(({
    'date': dateOnly.toIso8601String(),
    'present': present,
    'student_uid': student.uid,
    'student_name': student.name,
  }));

  await supabase.from('students')
      .update({
        'classes': student.classes+1,
        'classes_present': present? student.classesPresent+1 : student.classesPresent,
      })
      .eq('uid', student.uid);

}

Future<Map<String, dynamic>?> getAttendanceStatus(DateTime date, Student student) async {
  final supabase = Supabase.instance.client;
  final dateOnly = DateTime(date.year, date.month, date.day).toIso8601String();

  try {
    final result = await supabase
        .from('attendance')
        .select('present')
        .eq('student_uid', student.uid)
        .eq('date', dateOnly)
        .maybeSingle();
    return result;
  } catch (e) {
    print('Error fetching attendance: $e');
    return null;
  }
}
