import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salary_record.dart';

class SalaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userSalariesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('salaries');
  }

  Future<void> addSalary({required String userId, required SalaryRecord record}) async {
    try {
      final col = _userSalariesCollection(userId);
      if (record.id.isEmpty) {
        await col.add(record.toMap());
      } else {
        await col.doc(record.id).set(record.toMap());
      }
    } catch (e) {
      print('Error adding salary: $e');
      rethrow;
    }
  }

  Stream<List<SalaryRecord>> streamSalaries({required String userId}) {
    try {
      final col = _userSalariesCollection(userId);
      return col
          .orderBy('date', descending: true)
          .snapshots()
          .map<List<SalaryRecord>>((snap) {
            try {
              return snap.docs.map((d) => SalaryRecord.fromDoc(d)).toList();
            } catch (e) {
              print('Error mapping salary documents: $e');
              return <SalaryRecord>[];
            }
          })
          .handleError((e) {
            print('Error in streamSalaries: $e');
          })
          .cast<List<SalaryRecord>>();
    } catch (e) {
      print('Error creating salaries stream: $e');
      // Return a stream that emits an empty list
      return Stream.value([]);
    }
  }

  Future<void> deleteSalary({required String userId, required String salaryId}) async {
    try {
      await _userSalariesCollection(userId).doc(salaryId).delete();
    } catch (e) {
      print('Error deleting salary: $e');
      rethrow;
    }
  }

  Stream<double> streamMonthlyTotal({required String userId, required DateTime month}) {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 1);
      final col = _userSalariesCollection(userId);

      return col
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
              isLessThan: Timestamp.fromDate(end))
          .snapshots()
          .map<double>((snap) {
            try {
              double total = 0;
              for (final d in snap.docs) {
                final data = d.data();
                total += (data['amount'] as num).toDouble();
              }
              return total;
            } catch (e) {
              print('Error calculating monthly total: $e');
              return 0.0;
            }
          })
          .handleError((e) {
            print('Error in streamMonthlyTotal: $e');
          })
          .cast<double>();
    } catch (e) {
      print('Error creating monthly total stream: $e');
      // Return a stream that emits 0.0
      return Stream.value(0.0);
    }
  }
}
