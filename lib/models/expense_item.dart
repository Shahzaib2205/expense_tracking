import 'package:cloud_firestore/cloud_firestore.dart';

enum EntryType { income, expense }

class ExpenseItem {
  const ExpenseItem({
    this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
    this.notes,
  });

  final String? id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final EntryType type;
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'type': type.name,
      'notes': notes,
    };
  }

  factory ExpenseItem.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    EntryType defaultType = EntryType.expense,
  }) {
    final data = doc.data() ?? <String, dynamic>{};
    final timestamp = data['date'] as Timestamp?;
    final typeName = data['type'] as String?;

    return ExpenseItem(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'Others',
      date: timestamp?.toDate() ?? DateTime.now(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: typeName == 'income'
          ? EntryType.income
          : typeName == 'expense'
              ? EntryType.expense
              : defaultType,
      notes: data['notes'] as String?,
    );
  }
}
