import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:the_project/pages/admin/data/batch.dart';
import 'package:the_project/pages/admin/data/student.dart';

class FirestoreService {
  final CollectionReference dayBatches = FirebaseFirestore.instance.collection('day_batches');
  final CollectionReference attendance = FirebaseFirestore.instance.collection('attendance');

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
        marked: false,
        students: (batch['students'] as List<dynamic>).map((s) {
          return Student(
            name: s['name'],
          );
        }).toList(),
      );
    }).toList();
  }

  Future<void> saveBatchesForDay(DateTime date, List<Batch> batches) async {
    String dayKey = _getWeekdayKey(date);
    await dayBatches.doc(dayKey).update({
      'batches': batches.map((b) => {
        'name': b.name,
        'timing': b.timing,
        'marked': false,
        'students': b.students.map((s) => {
          'name': s.name,
        }).toList(),
      }).toList(),
    });
  }

  Future<void> updateAttendance(DateTime date, List<Batch> updatedBatches) async {
    await saveBatchesForDay(date, updatedBatches); // just overwrite for now
  }

  Future<void> saveAttendanceForBatch(List<Batch> newBatches, DateTime date) async {

    final docRef = attendance.doc(date.toIso8601String());
    final docSnap = await docRef.get();

    List<Map<String, dynamic>> existingBatchMaps = [];

    if (docSnap.exists && docSnap.data() != null) {
      final data = docSnap.data() as Map<String, dynamic>;
      final List<dynamic> existingBatches = data['batches'] ?? [];

      existingBatchMaps = existingBatches.cast<Map<String, dynamic>>();
    }

    final newBatchMaps = newBatches.map((b) => {
      'name': b.name,
      'timing': b.timing,
      'marked': b.marked,
      'students': b.students.map((s) => {
        'name': s.name,
        'present': s.present
      }).toList()
    }).toList();

    final updateBatchMaps = [...existingBatchMaps.where((existing) => !newBatchMaps.any((b) => b['name'] == existing['name'])), ...newBatchMaps];

    await docRef.set({'batches': updateBatchMaps});
  }
}