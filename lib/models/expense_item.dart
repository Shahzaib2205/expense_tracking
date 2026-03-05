enum EntryType { income, expense }

class ExpenseItem {
  const ExpenseItem({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
  });

  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final EntryType type;
}
