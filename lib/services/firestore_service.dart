import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/data/student.dart';

class FirestoreService {
  final CollectionReference dayBatches = FirebaseFirestore.instance.collection('day_batches');

  String _getWeekdayKey(DateTime date) => DateFormat('E').format(date);

  Future<List<Batch>> getBatchesForDay(DateTime date) async {
    String dayKey = _getWeekdayKey(date);
    final doc = await dayBatches.doc(dayKey).get();

    if (!doc.exists || doc.data() == null) return [];

    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> batchesData = data['batches'] ?? [];

    return batchesData.map((batch) {
      return Batch(
        name: batch['name'],
        timing: batch['timing'],
        students: (batch['students'] as List<dynamic>).map((s) {
          return Student(
            name: s['name'],
          )..attendance = Map<String, bool>.from(s['attendance'] ?? {});
        }).toList(),
      );
    }).toList();
  }

  Future<void> saveBatchesForDay(DateTime date, List<Batch> batches) async {
    String dayKey = _getWeekdayKey(date);
    await dayBatches.doc(dayKey).set({
      'batches': batches.map((b) => {
        'name': b.name,
        'timing': b.timing,
        'students': b.students.map((s) => {
          'name': s.name,
          'attendance': s.attendance,
        }).toList(),
      }).toList(),
    });
  }

  Future<void> updateAttendance(DateTime date, List<Batch> updatedBatches) async {
    await saveBatchesForDay(date, updatedBatches); // just overwrite for now
  }
}