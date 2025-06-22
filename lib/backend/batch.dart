import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Batch {
  final String name;
  final String uid;
  final String day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const Batch({required this.name, required this.uid, required this.day, required this.endTime, required this.startTime});

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

Future<void> insertBatch({
  required String name,
  required String day,
  required TimeOfDay startTime,
  required TimeOfDay endTime,
}) async {
  final supabase = Supabase.instance.client;

  // Helper to format TimeOfDay as "HH:mm"
  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  try {
    await supabase.from('batches').insert({
      'name': name,
      'day': day,
      'start_time': formatTime(startTime),
      'end_time': formatTime(endTime),
    });
  } catch (e) {
    debugPrint('Batch Insert failed: $e');
    throw Exception('Insert failed: $e');
  }
}

Future<void> deleteBatch(String batchUid) async {
  final supabase = Supabase.instance.client;
  try {
    await supabase.from('batches').delete().eq('batch_uid', batchUid);
  } catch (e) {
    debugPrint("Remove failed: $e");
    throw Exception('Remove failed: $e');
  }
}

