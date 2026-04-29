import 'package:cloud_firestore/cloud_firestore.dart';

class SalaryRecord {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;

  SalaryRecord({required this.id, required this.amount, required this.date, this.notes});

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
    };
  }

  factory SalaryRecord.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['date'] as Timestamp?;
    return SalaryRecord(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      date: ts?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String?,
    );
  }
}
