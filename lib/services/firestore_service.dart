import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:the_project/app/admin/data/batch.dart';
import 'package:the_project/app/admin/data/student.dart';

class FirestoreService {
  final CollectionReference dayBatches = FirebaseFirestore.instance.collection('day_batches');
  final CollectionReference attendance = FirebaseFirestore.instance.collection('attendance');

  String _getWeekdayKey(DateTime date) => DateFormat('E').format(date);

  // Function to retrieve DATE-wise batch-data (Used in marking attendance functionality)
  Future<List<Batch>> getBatchesForDate(DateTime date) async {
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

  // Function to retrieve only DAY-wise batch-data (Used in view_batches.dart)
  Future<List<Batch>> getBatchesForDay(String weekday) async {
    
    String dayKey = weekday.substring(0,3);

    final dayDoc = await dayBatches.doc(dayKey).get();

    if (!dayDoc.exists || dayDoc.data() == null) return [];

    final dayData = dayDoc.data() as Map<String, dynamic>;
    final List<dynamic> batchesData = dayData['batches'] ?? [];

    return batchesData.map((batch) {
      final String batchName = batch['name'];

      return Batch(
        name: batchName,
        timing: batch['timing'],
        students: (batch['students'] as List<dynamic>).map((s) {
          final String studentName = s['name'];
          return Student(
            name: studentName,
          );
        }).toList(),
      );
    }).toList();
  }

  // Function to save/create a new batch for a particular weekday
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

  // Function to save the attendance for students of a batch on a particular date
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

  // Function to remove a specific batch from a specific weekday
  Future<void> deleteBatchFromDay(String weekday, Batch batchToDelete) async {
    final String dayKey = weekday.substring(0, 3);
    final docRef = dayBatches.doc(dayKey);
    final docSnap = await docRef.get();

    if (!docSnap.exists || docSnap.data() == null) return;

    final data = docSnap.data() as Map<String, dynamic>;
    final List<dynamic> batches = data['batches'] ?? [];

    // Remove the batch with the same name
    final updatedBatches = batches.where((b) {
      if (b is Map<String, dynamic> && b.containsKey('name')) {
        return b['name'] != batchToDelete.name;
      }
      return true;
    }).toList();

    // Update Firestore
    await docRef.set({'batches': updatedBatches});
  }

  // Function to remove a specific student from a specific batch from a specific weekday
  Future<void> deleteStudentFromBatchInDay(String weekday, Batch batch, Student studentToDelete) async {
    final String dayKey = weekday.substring(0, 3);
    final docRef = dayBatches.doc(dayKey);
    final docSnap = await docRef.get();

    if (!docSnap.exists || docSnap.data() == null) return;

    final data = docSnap.data() as Map<String, dynamic>;
    final List<dynamic> batches = data['batches'] ?? [];

    // Reconstruct the updated batch list with the student removed from the target batch
    final updatedBatches = batches.map((b) {
      if (b is Map<String, dynamic> && b['name'] == batch.name) {
        final List<dynamic> students = b['students'] ?? [];

        final updatedStudents = students.where((s) {
          if (s is Map<String, dynamic> && s.containsKey('name')) {
            return s['name'] != studentToDelete.name;
          }
          return true;
        }).toList();

        return {
          ...b,
          'students': updatedStudents,
        };
      } else {
        return b;
      }
    }).toList();

    await docRef.set({'batches': updatedBatches});
  }

  // Function to add a student to a specific batch on a specific weekday
  Future<void> addStudentToBatchOnDay(String weekday, Batch batch, Student student) async {
    final String dayKey = weekday.substring(0, 3);
    final docRef = dayBatches.doc(dayKey);
    final docSnap = await docRef.get();

    if (!docSnap.exists || docSnap.data() == null) return;

    final data = docSnap.data() as Map<String, dynamic>;
    final List<dynamic> batches = data['batches'] ?? [];

    final updatedBatches = batches.map((b) {
      if (b is Map<String, dynamic> && b['name'] == batch.name) {
        final List<dynamic> students = b['students'] ?? [];

        // Check if student already exists
        final studentExists = students.any((s) =>
            s is Map<String, dynamic> && s['name'] == student.name);

        if (!studentExists) {
          students.add({'name': student.name});
        }

        return {
          ...b,
          'students': students,
        };
      } else {
        return b;
      }
    }).toList();

    await docRef.set({'batches': updatedBatches});
  }

  // Assign roles
  Future<void> assignRole(String email, String role) async {
    await FirebaseFirestore.instance.collection('users').doc(email).set({
      'role': role,
    });
  }

}
