import 'package:supabase_flutter/supabase_flutter.dart';

class Student {
  final String name;
  final String? uid;
  final int classesAttended;

  const Student({required this.name, this.uid, this.classesAttended = 0});

  factory Student.fromMap(Map<String, dynamic> map) => Student(
      name: map['name'],
      uid: map['uid']
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
