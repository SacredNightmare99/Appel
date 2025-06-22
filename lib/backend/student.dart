import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_project/backend/batch.dart';

class Student {
  final String name;
  final String uid;
  final String? batchUid;
  final String? batchName;
  final int classesAttended;

  const Student({required this.name, required this.uid, this.batchUid, this.batchName, this.classesAttended = 0});

  factory Student.fromMap(Map<String, dynamic> map) => Student(
      name: map['name'],
      uid: map['uid'],
      batchUid: map['batch_id'],
      batchName: map['batch_name'],
    );

}


Future<void> insertStudent(String name) async {
  final supabase = Supabase.instance.client;

  try {
    await supabase.from('students').insert({'name': name});
  } catch (e) {
    throw Exception('Insert failed: $e');
  }
}

Future<void> deleteStudent(String uid) async {
  final supabase = Supabase.instance.client;

  try {
    await supabase.from('students').delete().eq('uid', uid);
  } catch (e) {
    throw Exception('Remove failed: $e');
  }

}

Future<List<Student>> getUnassignedStudents() async {
  final supabase = Supabase.instance.client;
  
  try {
    final data = await supabase
        .from('students')
        .select()
        .filter('batch_id', 'is', null);
    return (data as List)
        .map((item) => Student.fromMap(item))
        .toList();
  } catch (e) {
    debugPrint('Fetch Failed: $e');
    throw Exception('Fetch failed: $e');
  }

}

Future<void> assignStudentToBatch(Student student, Batch batch) async {
  final supabase = Supabase.instance.client;

  await supabase
    .from('students')
    .update({
      'batch_id': batch.uid,
      'batch_name': batch.name
    })
    .eq('uid', student.uid);
  
}

Future<void> unassignStudentFromBatch(Student student) async {
  final supabase = Supabase.instance.client;

  await supabase
    .from('students')
    .update({
      'batch_id': null,
      'batch_name': null,
    })
    .eq('uid', student.uid);

}
