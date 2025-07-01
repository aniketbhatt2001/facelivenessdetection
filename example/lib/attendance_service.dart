import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final _firestore = FirebaseFirestore.instance;

  /// Registers a new employee
  Future<bool> registerEmployee(
      {required String employeeId, required String name}) async {
    try {
      final docRef =
          _firestore.collection('employees').doc('${name}_$employeeId');

      final ref = FirebaseFirestore.instance
          .collection('employees')
          .doc('${name}_$employeeId');
      final snapshot = await ref.get(); // safe — no document is created

      if (snapshot.exists) {
        print("Document exists.");
        throw Exception('User already exists');
      } else {
        print("Document doesn't exist.");
        await docRef.set({
          'name': name,
          'faceRegistered': true,
          'registrationDate': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Returns date in format YYYYMMDD
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  /// Check-in logic
  Future<void> checkIn({
    required String employeeId,
  }) async {
    final dateKey = _todayKey();
    final docId = '${employeeId}_$dateKey';

    final attendanceRef = _firestore.collection('attendance').doc(docId);

    await attendanceRef.set({
      'employeeId': employeeId,
      'date': dateKey,
      'checkIn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check-out logic
  Future<void> checkOut({
    required String employeeId,
    String? checkOutImageUrl,
  }) async {
    final dateKey = _todayKey();
    final docId = '${employeeId}_$dateKey';

    final attendanceRef = _firestore.collection('attendance').doc(docId);

    final snapshot = await attendanceRef.get();
    if (!snapshot.exists) {
      throw Exception('Check-in not found for today.');
    }

    await attendanceRef.update({
      'checkOut': FieldValue.serverTimestamp(),
      'checkOutImageUrl': checkOutImageUrl,
    });
  }

  /// Stream of today's attendance for UI
  Stream<DocumentSnapshot<Map<String, dynamic>>> todayAttendanceStream(
      String employeeId) {
    final dateKey = _todayKey();
    final docId = '${employeeId}_$dateKey';
    return _firestore.collection('attendance').doc(docId).snapshots();
  }
}
