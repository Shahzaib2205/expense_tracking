import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/salary_record.dart';

class SalaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userSalariesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('salaries');
  }

  Future<void> addSalary({required String userId, required SalaryRecord record}) async {
    final col = _userSalariesCollection(userId);
    if (record.id.isEmpty) {
      await col.add(record.toMap());
    } else {
      await col.doc(record.id).set(record.toMap());
    }
  }

  Stream<List<SalaryRecord>> streamSalaries({required String userId}) {
    final col = _userSalariesCollection(userId);
    return col.orderBy('date', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => SalaryRecord.fromDoc(d)).toList();
    });
  }

  Future<void> deleteSalary({required String userId, required String salaryId}) async {
    await _userSalariesCollection(userId).doc(salaryId).delete();
  }

  Stream<double> streamMonthlyTotal({required String userId, required DateTime month}) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final col = _userSalariesCollection(userId);

    return col.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start), isLessThan: Timestamp.fromDate(end)).snapshots().map((snap) {
      double total = 0;
      for (final d in snap.docs) {
        final data = d.data();
        total += (data['amount'] as num).toDouble();
      }
      return total;
    });
  }
}
