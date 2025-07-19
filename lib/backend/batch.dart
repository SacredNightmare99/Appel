import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Batch {
  final String name;
  final String uid;
  final String day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const Batch({required this.name, required this.uid, required this.day, required this.endTime, required this.startTime});

  Batch copyWith({
    String? name,
    String? uid,
    String? day,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return Batch(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  // Helper to format TimeOfDay for Supabase
  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'batch_uid': uid,
      'day': day,
      'start_time': _formatTime(startTime),
      'end_time': _formatTime(endTime),
    };
  }

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

// --- Supabase Functions ---

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

Future<void> updateBatch(Batch batch) async {
  final supabase = Supabase.instance.client;
  try {
    final updateData = batch.toMap()..remove('batch_uid');
    
    await supabase
        .from('batches')
        .update(updateData)
        .eq('batch_uid', batch.uid);
  } catch (e) {
    debugPrint('Batch Update failed: $e');
    throw Exception('Update failed: $e');
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

