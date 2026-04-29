import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/salary_record.dart';
import '../../models/expense_item.dart';
import '../../services/salary_service.dart';

class DashboardProvider extends ChangeNotifier {
  final SalaryService _salaryService = SalaryService();
  final List<SalaryRecord> _salaries = [];

  StreamSubscription<List<SalaryRecord>>? _subs;
  String? _userId;

  void setUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _subs?.cancel();
    _salaries.clear();
    if (_userId != null) {
      _subs = _salaryService.streamSalaries(userId: _userId!).listen((list) {
        _salaries
          ..clear()
          ..addAll(list);
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  List<SalaryRecord> get salaries => List.unmodifiable(_salaries);

  List<SalaryRecord> get recentSalaries {
    final copy = [..._salaries];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy.take(3).toList();
  }

  double get totalSalaryThisMonth {
    final now = DateTime.now();
    final monthSalaries = _salaries.where((s) => s.date.year == now.year && s.date.month == now.month);
    return monthSalaries.fold(0.0, (sum, s) => sum + s.amount);
  }

  Future<void> addSalary(SalaryRecord record) async {
    if (_userId == null) return;
    await _salaryService.addSalary(userId: _userId!, record: record);
  }

  Future<void> deleteSalary(String id) async {
    if (_userId == null) return;
    await _salaryService.deleteSalary(userId: _userId!, salaryId: id);
  }

  // --- Compatibility layer for existing UI expecting ExpenseItem-like API ---
  List<ExpenseItem> get items {
    return _salaries
        .map((s) => ExpenseItem(
              title: 'Salary',
              category: 'Salary',
              date: s.date,
              amount: s.amount,
              type: EntryType.income,
            ))
        .toList();
  }

  List<ExpenseItem> get recentTransactions => items.take(3).toList();

  double get totalIncome => _salaries.fold(0.0, (sum, s) => sum + s.amount);

  double get totalExpense => 0.0;

  double get balance => totalIncome - totalExpense;

  double get budgetCap => 20000;

  double get budgetUsedRatio => totalExpense / (budgetCap == 0 ? 1 : budgetCap);

  double get revenueLastWeek => totalIncome;

  double get foodLastWeek => 0.0;

  Map<String, double> get categoryTotals => {};

  void quickAddExpense() {
    // Not applicable for salary-only model; preserve API surface.
    notifyListeners();
  }

  @override
  void dispose() {
    _subs?.cancel();
    super.dispose();
  }
}
