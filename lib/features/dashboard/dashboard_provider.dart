import 'package:flutter/foundation.dart';

import 'package:expence_tracking/models/expense_item.dart';

class DashboardProvider extends ChangeNotifier {
  final List<ExpenseItem> _items = [
    ExpenseItem(
      title: 'Salary',
      category: 'Monthly',
      date: DateTime(2026, 4, 30, 18, 27),
      amount: 4000,
      type: EntryType.income,
    ),
    ExpenseItem(
      title: 'Groceries',
      category: 'Pantry',
      date: DateTime(2026, 4, 24, 17, 0),
      amount: 100,
      type: EntryType.expense,
    ),
    ExpenseItem(
      title: 'Rent',
      category: 'Rent',
      date: DateTime(2026, 4, 15, 8, 30),
      amount: 674.40,
      type: EntryType.expense,
    ),
    ExpenseItem(
      title: 'Utilities',
      category: 'Bills',
      date: DateTime(2026, 4, 2, 9, 15),
      amount: 413,
      type: EntryType.expense,
    ),
    ExpenseItem(
      title: 'Freelance Retainer',
      category: 'Income',
      date: DateTime(2026, 4, 1, 12, 0),
      amount: 4970.40,
      type: EntryType.income,
    ),
  ];

  List<ExpenseItem> get items => List.unmodifiable(_items);

  List<ExpenseItem> get recentTransactions {
    final copy = [..._items];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy.take(3).toList();
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

  double get budgetCap => 20000;

  double get budgetUsedRatio => 0.30;

  double get revenueLastWeek => 4000;

  double get foodLastWeek => 100;

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
