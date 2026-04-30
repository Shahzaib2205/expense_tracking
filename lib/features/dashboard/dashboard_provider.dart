import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/expense_item.dart';
import '../../models/salary_record.dart';
import '../../services/expense_service.dart';
import '../../services/salary_service.dart';

class DashboardProvider extends ChangeNotifier {
  final SalaryService _salaryService = SalaryService();
  final ExpenseService _expenseService = ExpenseService();

  final List<SalaryRecord> _salaries = [];
  final List<ExpenseItem> _expenses = [];

  StreamSubscription<List<SalaryRecord>>? _salarySub;
  StreamSubscription<List<ExpenseItem>>? _expenseSub;
  String? _userId;

  void setUser(String? userId) {
    if (_userId == userId) {
      return;
    }

    _userId = userId;
    _salarySub?.cancel();
    _expenseSub?.cancel();
    _salaries.clear();
    _expenses.clear();

    if (_userId == null) {
      notifyListeners();
      return;
    }

    _salarySub = _salaryService.streamSalaries(userId: _userId!).listen((list) {
      _salaries
        ..clear()
        ..addAll(list);
      notifyListeners();
    });

    _expenseSub = _expenseService.streamExpenses(userId: _userId!).listen((list) {
      _expenses
        ..clear()
        ..addAll(list);
      notifyListeners();
    });
  }

  List<SalaryRecord> get salaries => List.unmodifiable(_salaries);

  List<ExpenseItem> get expenses => List.unmodifiable(_expenses);

  List<ExpenseItem> get expenseItems => _expenses
      .where((item) => item.type == EntryType.expense)
      .toList(growable: false);

  List<SalaryRecord> get recentSalaries {
    final copy = [..._salaries];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy.take(3).toList();
  }

  List<ExpenseItem> get recentExpenses {
    final copy = [...expenseItems];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy.take(3).toList();
  }

  List<ExpenseItem> get items {
    final combined = <ExpenseItem>[
      ..._salaries.map(
        (salary) => ExpenseItem(
          title: 'Salary',
          category: 'Income',
          date: salary.date,
          amount: salary.amount,
          type: EntryType.income,
          notes: salary.notes,
        ),
      ),
      ..._expenses,
    ];
    combined.sort((a, b) => b.date.compareTo(a.date));
    return combined;
  }

  List<ExpenseItem> get recentTransactions => items.take(3).toList();

  double get totalSalaryThisMonth {
    final now = DateTime.now();
    final monthSalaries = _salaries.where(
      (salary) => salary.date.year == now.year && salary.date.month == now.month,
    );
    return monthSalaries.fold(0.0, (sum, salary) => sum + salary.amount);
  }

  double get totalIncome => _salaries.fold(0.0, (sum, salary) => sum + salary.amount);

  double get totalExpense => expenseItems.fold(0.0, (sum, item) => sum + item.amount);

  double get balance => totalIncome - totalExpense;

  double get budgetCap => 20000;

  double get budgetUsedRatio => totalExpense / (budgetCap == 0 ? 1 : budgetCap);

  double get revenueLastWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _salaries
        .where((salary) => salary.date.isAfter(cutoff))
        .fold(0.0, (sum, salary) => sum + salary.amount);
  }

  double get foodLastWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return expenseItems
        .where((item) => item.date.isAfter(cutoff) && item.category.toLowerCase() == 'food')
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (final item in expenseItems) {
      map.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }
    return map;
  }

  List<ExpenseItem> expenseItemsForCategory(String category) {
    final filtered = expenseItems
        .where((item) => item.category.toLowerCase() == category.toLowerCase())
        .toList();
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Future<void> addSalary(SalaryRecord record) async {
    if (_userId == null) {
      return;
    }
    await _salaryService.addSalary(userId: _userId!, record: record);
  }

  Future<void> addExpense(ExpenseItem record) async {
    if (_userId == null) {
      return;
    }
    await _expenseService.addExpense(userId: _userId!, record: record);
  }

  Future<void> deleteSalary(String id) async {
    if (_userId == null) {
      return;
    }
    await _salaryService.deleteSalary(userId: _userId!, salaryId: id);
  }

  Future<void> deleteExpense(String id) async {
    if (_userId == null) {
      return;
    }
    await _expenseService.deleteExpense(userId: _userId!, expenseId: id);
  }

  void quickAddExpense() {
    if (_userId == null) {
      return;
    }

    unawaited(
      addExpense(
        ExpenseItem(
          title: 'Quick Expense',
          category: 'Others',
          date: DateTime.now(),
          amount: 12,
          type: EntryType.expense,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _salarySub?.cancel();
    _expenseSub?.cancel();
    super.dispose();
  }
}
