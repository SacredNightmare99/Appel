import 'package:supabase_flutter/supabase_flutter.dart';

class Student {
  final String name;
  final String uid;
  final String?  batchUid;
  final int classesAttended;

  const Student({required this.name, required this.uid, this.batchUid, this.classesAttended = 0});

  factory Student.fromMap(Map<String, dynamic> map) => Student(
      name: map['name'],
      uid: map['uid'],
      batchUid: map['batch_id'],
    );

}

Stream<List<Student>> streamStudents() {
  final supabase = Supabase.instance.client;
  return supabase
      .from('students')
      .stream(primaryKey: ['uid'])
      .map((data) => data
          .map((item) => Student.fromMap(item))
          .toList());
}

Future<void> insertStudent(String name) async {
  final supabase = Supabase.instance.client;

  try {
    await supabase.from('students').insert({'name': name});
  } catch (e) {
    throw Exception('Insert failed: $e');
  }
}

Future<void> removeStudent(String uid) async {
  final supabase = Supabase.instance.client;

  try {
    await supabase.from('students').delete().eq('uid', uid);
  } catch (e) {
    throw Exception('Remove failed: $e');
  }

}
