import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/student.dart';

class Attendance {
  final int uid;
  final DateTime date;
  final bool present;
  final String studentUid;

  const Attendance({
    required this.uid,
    required this.date,
    this.present = false,
    required this.studentUid,
  });

  Attendance copyWith({
    int? uid,
    DateTime? date,
    bool? present,
    String? studentUid,
  }) {
    return Attendance(
      uid: uid ?? this.uid,
      date: date ?? this.date,
      present: present ?? this.present,
      studentUid: studentUid ?? this.studentUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': date.toIso8601String(),
      'present': present,
      'student_uid': studentUid,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) => Attendance(
        uid: map['uid'], // Added uid
        date: DateTime.parse(map['date']),
        present: map['present'],
        studentUid: map['student_uid'],
      );
}

// --- Supabase Functions ---

Future<void> markAttendanceForStudent(Student student, bool present, DateTime date) async {
  final supabase = Supabase.instance.client;
  final dateOnly = DateTime(date.year, date.month, date.day);

  await supabase.from('attendance').insert(({
    'date': dateOnly.toIso8601String(),
    'present': present,
    'student_uid': student.uid,
    'student_name': student.name,
  }));

  await supabase.from('students').update({
    'classes': student.classes + 1,
    'classes_present': present ? student.classesPresent + 1 : student.classesPresent,
  }).eq('uid', student.uid);
}

// Toggles the status of an existing attendance record and updates student counts.
Future<void> updateAttendance(Attendance originalAttendance, Attendance updatedAttendance) async {
  final supabase = Supabase.instance.client;

  await supabase
      .from('attendance')
      .update({'present': updatedAttendance.present})
      .eq('uid', updatedAttendance.uid);

  int presentCountChange = 0;
  if (originalAttendance.present && !updatedAttendance.present) {
    presentCountChange = -1; // Was present, now absent
  } else if (!originalAttendance.present && updatedAttendance.present) {
    presentCountChange = 1; // Was absent, now present
  }

  if (presentCountChange != 0) {
    // Use rpc to safely increment the column
    await supabase.rpc('increment_classes_present', params: {
      'student_id': updatedAttendance.studentUid,
      'increment_value': presentCountChange,
    });
  }
}

/// Deletes an attendance record and updates the student's total counts.
Future<void> deleteAttendance(Attendance attendanceToDelete) async {
  final supabase = Supabase.instance.client;

  await supabase.from('attendance').delete().eq('uid', attendanceToDelete.uid);

  await supabase.rpc('decrement_student_attendance', params: {
    'student_id': attendanceToDelete.studentUid,
    'was_present': attendanceToDelete.present,
  });
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
