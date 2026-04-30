import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/expense_item.dart';
import '../../models/salary_record.dart';
import '../../services/expense_service.dart';
import '../../services/salary_service.dart';
import '../../services/realtime_db_service.dart';
import '../../shared/currency_utils.dart';

class DashboardProvider extends ChangeNotifier {
  final SalaryService _salaryService = SalaryService();
  final ExpenseService _expenseService = ExpenseService();
  final RealtimeDbService _realtimeDb = RealtimeDbService();

  final List<SalaryRecord> _salaries = [];
  final List<ExpenseItem> _expenses = [];

  StreamSubscription<List<SalaryRecord>>? _salarySub;
  StreamSubscription<List<ExpenseItem>>? _expenseSub;
  String? _userId;

  void setUser(String? userId) {
    if (_userId == userId) {
      return;
    }

    print('🔄 DashboardProvider.setUser called with userId: $userId');

    _userId = userId;
    _salarySub?.cancel();
    _expenseSub?.cancel();
    _salaries.clear();
    _expenses.clear();

    if (_userId == null) {
      print('❌ User ID is null, clearing data');
      notifyListeners();
      return;
    }

    print('✅ Subscribing to salary stream for user: $_userId');
    _salarySub = _salaryService.streamSalaries(userId: _userId!).listen(
      (list) {
        print('💰 Received ${list.length} salaries');
        _salaries
          ..clear()
          ..addAll(list);
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error in salary stream: $error');
      },
    );

    print('✅ Subscribing to expense stream for user: $_userId');
    _expenseSub = _expenseService.streamExpenses(userId: _userId!).listen(
      (list) {
        print('💳 Received ${list.length} expenses');
        _expenses
          ..clear()
          ..addAll(list);
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error in expense stream: $error');
      },
    );
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

  /// Transactions for a specific day (local time).
  List<ExpenseItem> transactionsForDay(DateTime day) {
    return items.where((it) {
      return it.date.year == day.year && it.date.month == day.month && it.date.day == day.day;
    }).toList();
  }

  /// Transactions for the 7-day period containing [reference]. Week starts on Sunday.
  List<ExpenseItem> transactionsForWeek(DateTime reference) {
    final int daysFromSunday = reference.weekday % 7; // Sunday -> 0
    final start = DateTime(reference.year, reference.month, reference.day).subtract(Duration(days: daysFromSunday));
    final end = start.add(const Duration(days: 7));
    return items.where((it) => it.date.isAtSameMomentAs(start) || (it.date.isAfter(start) && it.date.isBefore(end)) || it.date.isAtSameMomentAs(end)).toList();
  }

  /// Transactions for the month of [reference].
  List<ExpenseItem> transactionsForMonth(DateTime reference) {
    return items.where((it) => it.date.year == reference.year && it.date.month == reference.month).toList();
  }

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

  String get formattedBalance => CurrencyUtils.formatCurrency(balance);

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
      throw StateError('No authenticated user available for salary write');
    }
    // Add salary record to Firestore
    await _salaryService.addSalary(userId: _userId!, record: record);
    // Atomically increment the user's balance in Realtime Database
    try {
      await _realtimeDb.incrementBalance(userId: _userId!, delta: record.amount);
    } catch (_) {
      // If realtime update fails, we don't want to crash the UI; log or handle as needed.
    }
  }

  Future<void> addExpense(ExpenseItem record) async {
    if (_userId == null) {
      throw StateError('No authenticated user available for expense write');
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
