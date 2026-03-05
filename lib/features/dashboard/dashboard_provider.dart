import 'package:flutter/foundation.dart';

import 'package:expence_tracking/models/expense_item.dart';

class DashboardProvider extends ChangeNotifier {
  final List<ExpenseItem> _items = [
    ExpenseItem(
      title: 'Monthly Salary',
      category: 'Income',
      date: DateTime(2026, 3, 1),
      amount: 2800,
      type: EntryType.income,
    ),
    ExpenseItem(
      title: 'Groceries',
      category: 'Food',
      date: DateTime(2026, 3, 4),
      amount: 85,
      type: EntryType.expense,
    ),
    ExpenseItem(
      title: 'Internet Bill',
      category: 'Utilities',
      date: DateTime(2026, 3, 3),
      amount: 45,
      type: EntryType.expense,
    ),
    ExpenseItem(
      title: 'Taxi Ride',
      category: 'Transport',
      date: DateTime(2026, 3, 2),
      amount: 20,
      type: EntryType.expense,
    ),
    ExpenseItem(
      title: 'Freelance Work',
      category: 'Income',
      date: DateTime(2026, 3, 5),
      amount: 420,
      type: EntryType.income,
    ),
    ExpenseItem(
      title: 'Streaming Plan',
      category: 'Entertainment',
      date: DateTime(2026, 3, 5),
      amount: 16,
      type: EntryType.expense,
    ),
  ];

  List<ExpenseItem> get items => List.unmodifiable(_items);

  List<ExpenseItem> get recentTransactions {
    final copy = [..._items];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy.take(5).toList();
  }

  double get totalIncome {
    return _items
        .where((item) => item.type == EntryType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _items
        .where((item) => item.type == EntryType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final item in _items.where((item) => item.type == EntryType.expense)) {
      map.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }
    return map;
  }

  void quickAddExpense() {
    _items.insert(
      0,
      ExpenseItem(
        title: 'Quick Expense',
        category: 'Misc',
        date: DateTime.now(),
        amount: 12,
        type: EntryType.expense,
      ),
    );
    notifyListeners();
  }
}
