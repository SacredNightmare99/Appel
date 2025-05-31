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
    final dayDoc = await dayBatches.doc(dayKey).get();
    final attendanceDoc = await attendance.doc(date.toIso8601String()).get();

    if (!dayDoc.exists || dayDoc.data() == null) return [];

    final dayData = dayDoc.data() as Map<String, dynamic>;
    final List<dynamic> batchesData = dayData['batches'] ?? [];

    Map<String, bool> attendanceMarkedStatus = {};
    Map<String, Map<String, bool>> attendanceStudentStatus = {};

    if (attendanceDoc.exists && attendanceDoc.data() != null) {
      final attendanceData = attendanceDoc.data() as Map<String, dynamic>;
      final List<dynamic> attendanceBatches = attendanceData['batches'] ?? [];

      for (var batch in attendanceBatches) {

        final batchName = batch['name'];

        if (batch is Map<String, dynamic> && batch.containsKey('name')) {
          attendanceMarkedStatus[batchName] = batch['marked'] ?? false;
        }

        Map<String, bool> studentMap = {};
        final List<dynamic> students = batch['students'] ?? [];

        for (var s in students) {
          if (s is Map<String, dynamic> && s.containsKey('name')) {
            studentMap[s['name']] = s['present'] ?? false;
          }
        }

        attendanceStudentStatus[batchName] = studentMap;
      }
    }

    return batchesData.map((batch) {

      final String batchName = batch['name'];
      final bool marked = attendanceMarkedStatus[batchName] ?? false;
      final Map<String, bool> studentPresenceMap = attendanceStudentStatus[batchName] ?? {};


      return Batch(
        name: batchName,
        timing: batch['timing'],
        marked: marked,
        students: (batch['students'] as List<dynamic>).map((s) {
          final String studentName = s['name'];
          final bool present = studentPresenceMap[studentName] ?? false;

          return Student(
            name: studentName,
            present: present
          );
        }).toList(),
      );
    }).toList();
  }

  Future<void> saveBatchForDay(String day, List<Batch> newBatches) async {

    final docRef = dayBatches.doc(day.substring(0, 3));
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
      'marked': false,
      'students': b.students.map((s) => {
        'name': s.name
      }).toList()
    }).toList();

    final updateBatchMaps = [...existingBatchMaps.where((existing) => !newBatchMaps.any((b) => b['name'] == existing['name'])), ...newBatchMaps];

    await docRef.set({'batches': updateBatchMaps});
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
      'marked': true,
      'students': b.students.map((s) => {
        'name': s.name,
        'present': s.present
      }).toList()
    }).toList();

    final updateBatchMaps = [...existingBatchMaps.where((existing) => !newBatchMaps.any((b) => b['name'] == existing['name'])), ...newBatchMaps];

    await docRef.set({'batches': updateBatchMaps});
  }
}