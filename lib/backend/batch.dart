import 'package:supabase_flutter/supabase_flutter.dart';

class Batch {
  final String name;
  final String uid;
  final String day;

  const Batch({required this.name, required this.uid, required this.day});

  factory Batch.fromMap(Map<String, dynamic> map) => Batch(
    name: map['name'], 
    uid: map['batch_uid'],
    day: map['day'],
  );

}

Future<Batch?> getBatchForStudent(String batchUid) async {
  final supabase = Supabase.instance.client;
  if (batchUid.isEmpty) {
    return null; // or throw custom exception if needed
  }

  final data = await supabase
      .from('batches')
      .select()
      .eq('batch_uid', batchUid)
      .maybeSingle();

  if (data == null) return null;

  return Batch.fromMap(data);
}


