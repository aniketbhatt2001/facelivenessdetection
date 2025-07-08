import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example/controllers/employee/employee_attendance_cubit.dart';
import 'package:intl/intl.dart';

class EmployeeService {
  EmployeeService._();

  static final _firestore = FirebaseFirestore.instance;
  static int? _qdrantId;
  static final StreamController<int> _qdrantIdController =
      StreamController<int>.broadcast();

  static Stream<int> get qdrantIdStream =>
      _qdrantIdController.stream.onlyDuplicates();

  static StreamSink<int> get _sink => _qdrantIdController.sink;

  static Future<bool> registerEmployee(
      {required String qdrantId, required String name}) async {
    try {
      final docRef = _firestore.collection('employees').doc(qdrantId);

      final ref =
          FirebaseFirestore.instance.collection('employees').doc(qdrantId);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        print("Document exists.");
        throw Exception('User already exists');
      } else {
        print("Document doesn't exist.");
        await docRef.set({
          'name': name,
          'faceRegistered': true,
          'registrationDate': FieldValue.serverTimestamp(),
          'qdrantId': qdrantId
        });
        _qdrantId ??= int.tryParse(qdrantId);
        _sink.add(int.parse(qdrantId));
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> markAttendance({
    required String qdrantId,
  }) async {
    try {
      if (_qdrantId != null && _qdrantId.toString() != qdrantId) return;
      final docId = '$qdrantId';

      final date = DateTime.now();
      final formatedDate = DateFormat('dd-MM-yyyy').format(date);

      final attendanceDocRef = _firestore
          .collection('employees')
          .doc(docId)
          .collection('attendanceData')
          .doc(formatedDate);

      final snapshot = await attendanceDocRef.get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        final alreadyCheckedIn = data['checkIn'] == true;
        final alreadyCheckedOut = data['checkOut'] == true;

        if (!alreadyCheckedIn) {
          await attendanceDocRef.update({
            'checkIn': true,
            'checkInTime': FieldValue.serverTimestamp(),
          });
        } else if (alreadyCheckedIn && !alreadyCheckedOut) {
          await attendanceDocRef.update({
            'checkOut': true,
            'checkOutTime': FieldValue.serverTimestamp(),
          });
        }
      } else {
        await attendanceDocRef.set({
          'qdrantId': qdrantId,
          'checkIn': true,
          'checkInTime': FieldValue.serverTimestamp(),
          'checkOut': false,
        });
      }
      _qdrantId ??= int.tryParse(qdrantId);
      _sink.add(int.parse(qdrantId));
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceHistory(
      String qdrantId) async {
    try {
      final query = await _firestore
          .collection('employees')
          .doc(qdrantId)
          .collection('attendanceData')
          .get();

      final attendanceList =
          query.docs.map((snapshot) => snapshot.data()).toList();

      return attendanceList;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentDateEmployeeAttendance(
      String qdrantId) async {
    try {
      final date = DateTime.now();
      final formatedDate = DateFormat('dd-MM-yyyy').format(date);
      final query = _firestore
          .collection('employees')
          .doc(qdrantId)
          .collection('attendanceData')
          .doc(formatedDate);

      final documentSnapshot = await query.get();
      final doc = documentSnapshot.data();
      return doc;
    } catch (e) {
      rethrow;
    }
  }

  /// Disposer to close the stream controller
  static void dispose() {
    _qdrantIdController.close();
  }

  static Map<String, List<Map<String, dynamic>>> groupByMonth(
      List<Map<String, dynamic>> attendanceList) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var record in attendanceList) {
      final checkInTime = (record['checkInTime'] as Timestamp).toDate();

      // Format as 'yyyy-MM'
      final monthKey =
          '${checkInTime.year}-${checkInTime.month.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }

      grouped[monthKey]!.add(record);
    }

    return grouped;
  }
}
