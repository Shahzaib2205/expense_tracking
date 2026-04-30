import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense_item.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userExpensesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  Future<void> addExpense({required String userId, required ExpenseItem record}) async {
    final collection = _userExpensesCollection(userId);
    if (record.id == null || record.id!.isEmpty) {
      await collection.add(record.toMap());
    } else {
      await collection.doc(record.id).set(record.toMap());
    }
  }

  Stream<List<ExpenseItem>> streamExpenses({required String userId}) {
    return _userExpensesCollection(userId).orderBy('date', descending: true).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => ExpenseItem.fromDoc(doc)).toList(),
    );
  }

  Future<void> deleteExpense({required String userId, required String expenseId}) async {
    await _userExpensesCollection(userId).doc(expenseId).delete();
  }
}