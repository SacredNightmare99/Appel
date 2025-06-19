import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Batch {
  final String name;
  final String uid;
  final String? day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const Batch({required this.name, required this.uid, this.day, required this.endTime, required this.startTime});

  factory Batch.fromMap(Map<String, dynamic> map) {

    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    
    return Batch(
      name: map['name'], 
      uid: map['batch_uid'],
      day: map['day'],
      startTime: parseTime(map['start_time']),
      endTime: parseTime(map['end_time']),
    );
  }

}

Future<Batch?> getBatchForStudent(String batchUid) async {
  final supabase = Supabase.instance.client;
  if (batchUid.isEmpty) {
    return null;
  }

  final data = await supabase
      .from('batches')
      .select()
      .eq('batch_uid', batchUid)
      .maybeSingle();

  if (data == null) return null;

  return Batch.fromMap(data);
}

Stream<List<Batch>> streamBatches() {
  final supabase = Supabase.instance.client;

  return supabase.from("batches")
      .stream(primaryKey: ['batch_uid'])
      .map((data) => data
            .map((item) => Batch.fromMap(item))
            .toList());
}

Stream<List<Batch>> streamBatchesByDay(String day) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('batches')
      .stream(primaryKey: ['batch_uid'])
      .eq('day', day)
      .map((data) => data
          .map((item) => Batch.fromMap(item))
          .toList());
}
