import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense_item.dart';

class ExpenseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userExpensesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  Future<void> addExpense({required String userId, required ExpenseItem record}) async {
    try {
      final collection = _userExpensesCollection(userId);
      if (record.id == null || record.id!.isEmpty) {
        await collection.add(record.toMap());
      } else {
        await collection.doc(record.id).set(record.toMap());
      }
    } catch (e) {
      print('Error adding expense: $e');
      rethrow;
    }
  }

  Stream<List<ExpenseItem>> streamExpenses({required String userId}) {
    try {
      return _userExpensesCollection(userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map<List<ExpenseItem>>((snapshot) {
            try {
              return snapshot.docs.map((doc) => ExpenseItem.fromDoc(doc)).toList();
            } catch (e) {
              print('Error mapping expense documents: $e');
              return <ExpenseItem>[];
            }
          })
          .handleError((e) {
            print('Error in streamExpenses: $e');
          })
          .cast<List<ExpenseItem>>();
    } catch (e) {
      print('Error creating expenses stream: $e');
      // Return a stream that emits an empty list
      return Stream.value([]);
    }
  }

  Future<void> deleteExpense({required String userId, required String expenseId}) async {
    try {
      await _userExpensesCollection(userId).doc(expenseId).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      rethrow;
    }
  }
}