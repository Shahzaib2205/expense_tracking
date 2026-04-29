import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence_tracking/app/app_theme.dart';
import 'package:expence_tracking/features/dashboard/dashboard_provider.dart';
import 'package:expence_tracking/models/expense_item.dart';
import 'package:expence_tracking/models/salary_record.dart';

enum _AnalysisPeriod { daily, weekly, monthly, yearly }

enum _TransferFilter { all, income, expense }

enum _CategoryFlowMode { overview, list, add }

enum _ProfileFlowMode {
  menu,
  account,
  edit,
  security,
  pinLock,
  biometric,
  terms,
}

class _AnalysisSnapshot {
  const _AnalysisSnapshot({
    required this.income,
    required this.expense,
    required this.incomeBars,
    required this.expenseBars,
    required this.labels,
  });

  final double income;
  final double expense;
  final List<double> incomeBars;
  final List<double> expenseBars;
  final List<String> labels;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;
  _AnalysisPeriod _analysisPeriod = _AnalysisPeriod.daily;
  _TransferFilter _transferFilter = _TransferFilter.all;
  _CategoryFlowMode _categoryFlowMode = _CategoryFlowMode.overview;
  String _selectedCategoryName = 'Food';
  bool _analysisSearchMode = false;
  bool _analysisSearched = false;

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
      if (index != 1) {
        _analysisSearchMode = false;
      }
      if (index != 3) {
        _categoryFlowMode = _CategoryFlowMode.overview;
      }
    });
  }

  void _showAddSalaryDialog(DashboardProvider dashboard) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Salary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Salary Amount', hintText: '0.00'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'Add notes...'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount != null && amount > 0) {
                final record = SalaryRecord(
                  id: '',
                  amount: amount,
                  date: DateTime.now(),
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                dashboard.addSalary(record);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Salary added successfully')),
                );
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openCategoryList(String name) {
    setState(() {
      _selectedCategoryName = name;
      _categoryFlowMode = _CategoryFlowMode.list;
    });
  }

  void _openCategoryAddExpense() {
    setState(() {
      _categoryFlowMode = _CategoryFlowMode.add;
    });
  }

  void _backFromCategoryFlow() {
    setState(() {
      if (_categoryFlowMode == _CategoryFlowMode.add) {
        _categoryFlowMode = _CategoryFlowMode.list;
      } else {
        _categoryFlowMode = _CategoryFlowMode.overview;
      }
    });
  }

  void _saveCategoryExpense() {
    setState(() {
      _categoryFlowMode = _CategoryFlowMode.list;
    });
  }

  String _formatCurrency(double value, {bool showSign = false}) {
    final absolute = value.abs();
    final parts = absolute.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    final prefix = showSign && value < 0 ? '-\$' : '\$';
    return '$prefix$whole.${parts[1]}';
  }

  String _timeDateLabel(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute - ${months[date.month - 1]} ${date.day}';
  }

  IconData _transactionIcon(String title) {
    final key = title.toLowerCase();
    if (key.contains('salary')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (key.contains('grocer')) {
      return Icons.shopping_basket_rounded;
    }
    if (key.contains('rent')) {
      return Icons.home_work_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  _AnalysisSnapshot _analysisSnapshotFor(_AnalysisPeriod period) {
    switch (period) {
      case _AnalysisPeriod.daily:
        return const _AnalysisSnapshot(
          income: 4120,
          expense: 1187.40,
          incomeBars: [0.22, 0.38, 0.33, 0.48, 0.43, 0.37, 0.52],
          expenseBars: [0.14, 0.16, 0.19, 0.21, 0.17, 0.16, 0.2],
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        );
      case _AnalysisPeriod.weekly:
        return const _AnalysisSnapshot(
          income: 11420,
          expense: 20000,
          incomeBars: [0.28, 0.35, 0.44, 0.31],
          expenseBars: [0.42, 0.47, 0.51, 0.43],
          labels: ['1st Wk', '2nd Wk', '3rd Wk', '4th Wk'],
        );
      case _AnalysisPeriod.monthly:
        return const _AnalysisSnapshot(
          income: 47200,
          expense: 35160,
          incomeBars: [0.32, 0.38, 0.48, 0.52, 0.44, 0.49],
          expenseBars: [0.26, 0.3, 0.39, 0.35, 0.33, 0.36],
          labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        );
      case _AnalysisPeriod.yearly:
        return const _AnalysisSnapshot(
          income: 430560,
          expense: 320300,
          incomeBars: [0.3, 0.34, 0.39, 0.45, 0.42],
          expenseBars: [0.22, 0.24, 0.3, 0.32, 0.29],
          labels: ['2019', '2020', '2021', '2022', '2023'],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintSurface,
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, dashboard, _) {
            return IndexedStack(
              index: _selectedNavIndex,
              children: [
                _DashboardHomeTab(
                  dashboard: dashboard,
                  formatCurrency: _formatCurrency,
                  timeDateLabel: _timeDateLabel,
                  transactionIcon: _transactionIcon,
                ),
                _DashboardAnalysisTab(
                  dashboard: dashboard,
                  snapshot: _analysisSnapshotFor(_analysisPeriod),
                  selectedPeriod: _analysisPeriod,
                  isSearchMode: _analysisSearchMode,
                  searchExecuted: _analysisSearched,
                  onPeriodChange: (period) {
                    setState(() {
                      _analysisPeriod = period;
                      _analysisSearchMode = false;
                    });
                  },
                  onSearchModeToggle: () {
                    setState(() {
                      _analysisSearchMode = !_analysisSearchMode;
                    });
                  },
                  onRunSearch: () {
                    setState(() {
                      _analysisSearched = true;
                    });
                  },
                  formatCurrency: _formatCurrency,
                ),
                _DashboardTransferTab(
                  dashboard: dashboard,
                  selectedFilter: _transferFilter,
                  onFilterChange: (filter) {
                    setState(() {
                      _transferFilter = filter;
                    });
                  },
                  formatCurrency: _formatCurrency,
                ),
                _DashboardCategoriesTab(
                  dashboard: dashboard,
                  flowMode: _categoryFlowMode,
                  selectedCategoryName: _selectedCategoryName,
                  onCategoryTap: _openCategoryList,
                  onAddExpenseTap: _openCategoryAddExpense,
                  onBackTap: _backFromCategoryFlow,
                  onSaveExpense: _saveCategoryExpense,
                  formatCurrency: _formatCurrency,
                ),
                const _DashboardProfileTab(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                final dashboard = context.read<DashboardProvider>();
                _showAddSalaryDialog(dashboard);
              },
              tooltip: 'Add Salary',
              backgroundColor: AppColors.primaryMint,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: _FixedBottomNavigation(
            selectedIndex: _selectedNavIndex,
            onTap: _onBottomNavTap,
          ),
        ),
      ),
    );
  }
}

class _DashboardHomeTab extends StatelessWidget {
  const _DashboardHomeTab({
    required this.dashboard,
    required this.formatCurrency,
    required this.timeDateLabel,
    required this.transactionIcon,
  });

  final DashboardProvider dashboard;
  final String Function(double value, {bool showSign}) formatCurrency;
  final String Function(DateTime date) timeDateLabel;
  final IconData Function(String title) transactionIcon;

  @override
  Widget build(BuildContext context) {
    final transactions = dashboard.recentTransactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryMint,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, Welcome Back',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 31,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Good Morning',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _CircleActionIcon(icon: Icons.notifications_none_rounded),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryMetric(
                          title: 'Total Balance',
                          value: formatCurrency(dashboard.balance),
                          valueColor: Colors.white,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 45,
                        color: Colors.white.withValues(alpha: 0.40),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: _SummaryMetric(
                            title: 'Total Expense',
                            value: formatCurrency(
                              -dashboard.totalExpense,
                              showSign: true,
                            ),
                            valueColor: const Color(0xFF176BFF),
                            alignEnd: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _BudgetProgressBar(
                    progress: dashboard.budgetUsedRatio,
                    capLabel: formatCurrency(dashboard.budgetCap),
                  ),
                  const SizedBox(height: 11),
                  const Row(
                    children: [
                      Icon(
                        Icons.check_box_outlined,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '30% Of Your Expenses, Looks Good.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.mintSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
              child: Column(
                children: [
                  _SavingsInsightCard(
                    revenueLabel: formatCurrency(dashboard.revenueLastWeek),
                    foodLabel: formatCurrency(
                      -dashboard.foodLastWeek,
                      showSign: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _HomePeriodSelector(),
                  const SizedBox(height: 16),
                  for (final item in transactions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DashboardTransactionRow(
                        icon: transactionIcon(item.title),
                        title: item.title,
                        dateLabel: timeDateLabel(item.date),
                        cadence: item.category,
                        amountLabel: formatCurrency(
                          item.type == EntryType.expense
                              ? -item.amount
                              : item.amount,
                          showSign: true,
                        ),
                        isExpense: item.type == EntryType.expense,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardAnalysisTab extends StatelessWidget {
  const _DashboardAnalysisTab({
    required this.dashboard,
    required this.snapshot,
    required this.selectedPeriod,
    required this.isSearchMode,
    required this.searchExecuted,
    required this.onPeriodChange,
    required this.onSearchModeToggle,
    required this.onRunSearch,
    required this.formatCurrency,
  });

  final DashboardProvider dashboard;
  final _AnalysisSnapshot snapshot;
  final _AnalysisPeriod selectedPeriod;
  final bool isSearchMode;
  final bool searchExecuted;
  final ValueChanged<_AnalysisPeriod> onPeriodChange;
  final VoidCallback onSearchModeToggle;
  final VoidCallback onRunSearch;
  final String Function(double value, {bool showSign}) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryMint,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      const Expanded(
                        child: Text(
                          'Analysis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _CircleActionIcon(
                        icon: isSearchMode
                            ? Icons.bar_chart_rounded
                            : Icons.search_rounded,
                        onTap: onSearchModeToggle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryMetric(
                          title: 'Total Balance',
                          value: formatCurrency(dashboard.balance),
                          valueColor: Colors.white,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.40),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: _SummaryMetric(
                            title: 'Total Expense',
                            value: formatCurrency(
                              -dashboard.totalExpense,
                              showSign: true,
                            ),
                            valueColor: const Color(0xFF176BFF),
                            alignEnd: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _AnalysisTopProgressBar(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.mintSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _AnalysisPeriodChip(
                          label: 'Daily',
                          selected: selectedPeriod == _AnalysisPeriod.daily,
                          onTap: () => onPeriodChange(_AnalysisPeriod.daily),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _AnalysisPeriodChip(
                          label: 'Weekly',
                          selected: selectedPeriod == _AnalysisPeriod.weekly,
                          onTap: () => onPeriodChange(_AnalysisPeriod.weekly),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _AnalysisPeriodChip(
                          label: 'Monthly',
                          selected: selectedPeriod == _AnalysisPeriod.monthly,
                          onTap: () => onPeriodChange(_AnalysisPeriod.monthly),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _AnalysisPeriodChip(
                          label: 'Yearly',
                          selected: selectedPeriod == _AnalysisPeriod.yearly,
                          onTap: () => onPeriodChange(_AnalysisPeriod.yearly),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isSearchMode)
                    _AnalysisSearchPanel(
                      transactions: dashboard.recentTransactions,
                      runSearch: onRunSearch,
                      showResult: searchExecuted,
                      formatCurrency: formatCurrency,
                    )
                  else
                    _AnalysisChartCard(
                      snapshot: snapshot,
                      formatCurrency: formatCurrency,
                    ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Targets',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintInput.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'No targets yet. Add goals in the next phase.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferRecord {
  const _TransferRecord({
    required this.title,
    required this.timeDateLabel,
    required this.cadence,
    required this.amount,
    required this.isExpense,
    required this.monthLabel,
    required this.icon,
  });

  final String title;
  final String timeDateLabel;
  final String cadence;
  final double amount;
  final bool isExpense;
  final String monthLabel;
  final IconData icon;
}

class _DashboardTransferTab extends StatelessWidget {
  const _DashboardTransferTab({
    required this.dashboard,
    required this.selectedFilter,
    required this.onFilterChange,
    required this.formatCurrency,
  });

  final DashboardProvider dashboard;
  final _TransferFilter selectedFilter;
  final ValueChanged<_TransferFilter> onFilterChange;
  final String Function(double value, {bool showSign}) formatCurrency;

  List<_TransferRecord> _records() {
    return const [
      _TransferRecord(
        title: 'Salary',
        timeDateLabel: '18:27 - April 30',
        cadence: 'Monthly',
        amount: 4000,
        isExpense: false,
        monthLabel: 'April',
        icon: Icons.layers_outlined,
      ),
      _TransferRecord(
        title: 'Groceries',
        timeDateLabel: '17:00 - April 24',
        cadence: 'Pantry',
        amount: 100,
        isExpense: true,
        monthLabel: 'April',
        icon: Icons.shopping_basket_outlined,
      ),
      _TransferRecord(
        title: 'Rent',
        timeDateLabel: '8:30 - April 15',
        cadence: 'Rent',
        amount: 674.40,
        isExpense: true,
        monthLabel: 'April',
        icon: Icons.volunteer_activism_outlined,
      ),
      _TransferRecord(
        title: 'Transport',
        timeDateLabel: '7:30 - April 08',
        cadence: 'Fuel',
        amount: 4.13,
        isExpense: true,
        monthLabel: 'April',
        icon: Icons.local_taxi_outlined,
      ),
      _TransferRecord(
        title: 'Others',
        timeDateLabel: '9:30 - April 12',
        cadence: 'Payments',
        amount: 120,
        isExpense: false,
        monthLabel: 'April',
        icon: Icons.layers_outlined,
      ),
      _TransferRecord(
        title: 'Food',
        timeDateLabel: '19:30 - March 31',
        cadence: 'Dinner',
        amount: 70.40,
        isExpense: true,
        monthLabel: 'March',
        icon: Icons.restaurant_outlined,
      ),
      _TransferRecord(
        title: 'Others',
        timeDateLabel: '9:30 - March 12',
        cadence: 'Upwork',
        amount: 340,
        isExpense: false,
        monthLabel: 'March',
        icon: Icons.layers_outlined,
      ),
      _TransferRecord(
        title: 'Others',
        timeDateLabel: '10:30 - February 28',
        cadence: 'Upwork',
        amount: 340,
        isExpense: false,
        monthLabel: 'February',
        icon: Icons.layers_outlined,
      ),
    ];
  }

  List<_TransferRecord> _filterRecords(
    List<_TransferRecord> items,
    _TransferFilter filter,
  ) {
    switch (filter) {
      case _TransferFilter.all:
        return items
            .where(
              (item) =>
                  item.title == 'Salary' ||
                  item.title == 'Groceries' ||
                  item.title == 'Rent' ||
                  item.title == 'Transport' ||
                  item.title == 'Food',
            )
            .toList();
      case _TransferFilter.income:
        return items.where((item) => !item.isExpense).toList();
      case _TransferFilter.expense:
        return items.where((item) => item.isExpense).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = _records();
    final filtered = _filterRecords(allRecords, selectedFilter);
    const monthOrder = ['April', 'March', 'February'];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryMint,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      Expanded(
                        child: Text(
                          'Transaction',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _CircleActionIcon(icon: Icons.notifications_none_rounded),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.mintSurface,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCurrency(dashboard.balance),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TransferMetricCard(
                          title: 'Income',
                          value: formatCurrency(4120),
                          icon: Icons.call_made_rounded,
                          selected: selectedFilter == _TransferFilter.income,
                          onTap: () {
                            onFilterChange(
                              selectedFilter == _TransferFilter.income
                                  ? _TransferFilter.all
                                  : _TransferFilter.income,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TransferMetricCard(
                          title: 'Expense',
                          value: formatCurrency(-1187.40, showSign: true),
                          icon: Icons.call_received_rounded,
                          selected: selectedFilter == _TransferFilter.expense,
                          onTap: () {
                            onFilterChange(
                              selectedFilter == _TransferFilter.expense
                                  ? _TransferFilter.all
                                  : _TransferFilter.expense,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.mintSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                children: [
                  for (
                    var monthIndex = 0;
                    monthIndex < monthOrder.length;
                    monthIndex++
                  ) ...[
                    Builder(
                      builder: (context) {
                        final month = monthOrder[monthIndex];
                        final monthItems = filtered
                            .where((item) => item.monthLabel == month)
                            .toList();
                        if (monthItems.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  month,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                if (monthIndex == 0)
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryMint,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            for (final item in monthItems)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 11),
                                child: _TransferTransactionRow(
                                  icon: item.icon,
                                  title: item.title,
                                  dateLabel: item.timeDateLabel,
                                  cadence: item.cadence,
                                  amountLabel: formatCurrency(
                                    item.isExpense ? -item.amount : item.amount,
                                    showSign: true,
                                  ),
                                  isExpense: item.isExpense,
                                ),
                              ),
                            const SizedBox(height: 2),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferMetricCard extends StatelessWidget {
  const _TransferMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF176BFF) : AppColors.mintSurface;
    final titleColor = selected ? Colors.white : AppColors.textPrimary;
    final valueColor = selected ? Colors.white : const Color(0xFF176BFF);
    final iconBg = selected
        ? Colors.white.withValues(alpha: 0.2)
        : AppColors.primaryMint.withValues(alpha: 0.16);
    final iconColor = selected ? Colors.white : AppColors.primaryMint;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 12, color: iconColor),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferTransactionRow extends StatelessWidget {
  const _TransferTransactionRow({
    required this.icon,
    required this.title,
    required this.dateLabel,
    required this.cadence,
    required this.amountLabel,
    required this.isExpense,
  });

  final IconData icon;
  final String title;
  final String dateLabel;
  final String cadence;
  final String amountLabel;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF63B1FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
        const SizedBox(width: 11),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: Color(0xFF176BFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 38,
          color: AppColors.primaryMint.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            cadence,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 38,
          color: AppColors.primaryMint.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            amountLabel,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isExpense
                  ? const Color(0xFF176BFF)
                  : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCardModel {
  const _CategoryCardModel({
    required this.name,
    required this.icon,
    this.isAddAction = false,
  });

  final String name;
  final IconData icon;
  final bool isAddAction;
}

class _CategoryExpenseEntry {
  const _CategoryExpenseEntry({
    required this.title,
    required this.timeDateLabel,
    required this.cadence,
    required this.amount,
    required this.monthLabel,
    required this.icon,
  });

  final String title;
  final String timeDateLabel;
  final String cadence;
  final double amount;
  final String monthLabel;
  final IconData icon;
}

class _DashboardCategoriesTab extends StatelessWidget {
  const _DashboardCategoriesTab({
    required this.dashboard,
    required this.flowMode,
    required this.selectedCategoryName,
    required this.onCategoryTap,
    required this.onAddExpenseTap,
    required this.onBackTap,
    required this.onSaveExpense,
    required this.formatCurrency,
  });

  final DashboardProvider dashboard;
  final _CategoryFlowMode flowMode;
  final String selectedCategoryName;
  final ValueChanged<String> onCategoryTap;
  final VoidCallback onAddExpenseTap;
  final VoidCallback onBackTap;
  final VoidCallback onSaveExpense;
  final String Function(double value, {bool showSign}) formatCurrency;

  List<_CategoryCardModel> _categoryCards() {
    return const [
      _CategoryCardModel(name: 'Food', icon: Icons.restaurant_outlined),
      _CategoryCardModel(name: 'Transport', icon: Icons.local_taxi_outlined),
      _CategoryCardModel(name: 'Medicine', icon: Icons.medication_outlined),
      _CategoryCardModel(
        name: 'Groceries',
        icon: Icons.shopping_basket_outlined,
      ),
      _CategoryCardModel(name: 'Rent', icon: Icons.house_outlined),
      _CategoryCardModel(name: 'Gifts', icon: Icons.card_giftcard_outlined),
      _CategoryCardModel(name: 'Snacks', icon: Icons.receipt_long_outlined),
      _CategoryCardModel(name: 'Others', icon: Icons.sell_outlined),
      _CategoryCardModel(
        name: 'Add Expense',
        icon: Icons.add_rounded,
        isAddAction: true,
      ),
    ];
  }

  Map<String, List<_CategoryExpenseEntry>> _entriesByCategory() {
    return const {
      'Food': [
        _CategoryExpenseEntry(
          title: 'Dinner',
          timeDateLabel: '9:31 - April 30',
          cadence: 'Meal',
          amount: 50,
          monthLabel: 'April',
          icon: Icons.restaurant_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Delivery Fee',
          timeDateLabel: '8:20 - April 24',
          cadence: 'Service',
          amount: 15.32,
          monthLabel: 'April',
          icon: Icons.delivery_dining_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Lunch',
          timeDateLabel: '11:20 - April 15',
          cadence: 'Meal',
          amount: 15.40,
          monthLabel: 'April',
          icon: Icons.lunch_dining_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Brunch',
          timeDateLabel: '11:00 - April 08',
          cadence: 'Meal',
          amount: 23,
          monthLabel: 'April',
          icon: Icons.fastfood_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Dinner',
          timeDateLabel: '19:30 - March 31',
          cadence: 'Meal',
          amount: 87.20,
          monthLabel: 'March',
          icon: Icons.restaurant_outlined,
        ),
      ],
      'Transport': [
        _CategoryExpenseEntry(
          title: 'Fuel',
          timeDateLabel: '7:30 - April 30',
          cadence: 'Fuel',
          amount: 25.30,
          monthLabel: 'April',
          icon: Icons.local_gas_station_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Car Parts',
          timeDateLabel: '9:15 - April 24',
          cadence: 'Parts',
          amount: 120.31,
          monthLabel: 'April',
          icon: Icons.car_repair_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Fuel',
          timeDateLabel: '7:30 - April 15',
          cadence: 'Fuel',
          amount: 87.15,
          monthLabel: 'April',
          icon: Icons.local_gas_station_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Car Wash',
          timeDateLabel: '6:30 - March 30',
          cadence: 'Service',
          amount: 11.14,
          monthLabel: 'March',
          icon: Icons.local_car_wash_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Public Transport',
          timeDateLabel: '7:15 - March 20',
          cadence: 'Ride',
          amount: 12.34,
          monthLabel: 'March',
          icon: Icons.directions_bus_outlined,
        ),
      ],
      'Groceries': [
        _CategoryExpenseEntry(
          title: 'Pantry',
          timeDateLabel: '8:17 - April 30',
          cadence: 'Pantry',
          amount: 133.30,
          monthLabel: 'April',
          icon: Icons.shopping_basket_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Snacks',
          timeDateLabel: '9:37 - April 24',
          cadence: 'Snacks',
          amount: 133.31,
          monthLabel: 'April',
          icon: Icons.cookie_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Canned Food',
          timeDateLabel: '7:50 - April 15',
          cadence: 'Canned',
          amount: 93.82,
          monthLabel: 'April',
          icon: Icons.ramen_dining_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Veggies',
          timeDateLabel: '6:30 - March 30',
          cadence: 'Veggies',
          amount: 147.43,
          monthLabel: 'March',
          icon: Icons.eco_outlined,
        ),
        _CategoryExpenseEntry(
          title: 'Groceries',
          timeDateLabel: '9:20 - March 20',
          cadence: 'Groceries',
          amount: 91.25,
          monthLabel: 'March',
          icon: Icons.shopping_cart_outlined,
        ),
      ],
    };
  }

  List<_CategoryExpenseEntry> _entriesForSelectedCategory() {
    final entries = _entriesByCategory();
    return entries[selectedCategoryName] ?? entries['Food']!;
  }

  String _titleForCurrentFlow() {
    switch (flowMode) {
      case _CategoryFlowMode.overview:
        return 'Categories';
      case _CategoryFlowMode.list:
        return selectedCategoryName;
      case _CategoryFlowMode.add:
        return 'Add Expenses';
    }
  }

  String _defaultExpenseTitle() {
    switch (selectedCategoryName) {
      case 'Transport':
        return 'Fuel';
      case 'Groceries':
        return 'Pantry';
      default:
        return 'Dinner';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryMint,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: flowMode == _CategoryFlowMode.overview
                            ? null
                            : onBackTap,
                        borderRadius: BorderRadius.circular(999),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: flowMode == _CategoryFlowMode.overview
                              ? AppColors.textPrimary.withValues(alpha: 0.7)
                              : AppColors.textPrimary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _titleForCurrentFlow(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const _CircleActionIcon(
                        icon: Icons.notifications_none_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryMetric(
                          title: 'Total Balance',
                          value: formatCurrency(dashboard.balance),
                          valueColor: Colors.white,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.40),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: _SummaryMetric(
                            title: 'Total Expense',
                            value: formatCurrency(
                              -dashboard.totalExpense,
                              showSign: true,
                            ),
                            valueColor: const Color(0xFF176BFF),
                            alignEnd: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  const _CategoryTopProgressBar(),
                  const SizedBox(height: 7),
                  const Row(
                    children: [
                      Icon(
                        Icons.check_box_outlined,
                        size: 15,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '25% Of Your Expenses, looks good.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.mintSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: switch (flowMode) {
                _CategoryFlowMode.overview => _CategoryOverviewContent(
                  cards: _categoryCards(),
                  onCardTap: (card) {
                    if (card.isAddAction) {
                      onAddExpenseTap();
                    } else {
                      onCategoryTap(card.name);
                    }
                  },
                ),
                _CategoryFlowMode.list => _CategoryListContent(
                  entries: _entriesForSelectedCategory(),
                  onAddExpenseTap: onAddExpenseTap,
                  formatCurrency: formatCurrency,
                ),
                _CategoryFlowMode.add => _CategoryAddExpenseContent(
                  selectedCategory: selectedCategoryName,
                  defaultTitle: _defaultExpenseTitle(),
                  onSaveExpense: onSaveExpense,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryOverviewContent extends StatelessWidget {
  const _CategoryOverviewContent({
    required this.cards,
    required this.onCardTap,
  });

  final List<_CategoryCardModel> cards;
  final ValueChanged<_CategoryCardModel> onCardTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return InkWell(
              key: ValueKey<String>('category-card-${card.name}'),
              onTap: () => onCardTap(card),
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: card.isAddAction
                          ? AppColors.primaryMint
                          : const Color(0xFF63B1FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(card.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryListContent extends StatelessWidget {
  const _CategoryListContent({
    required this.entries,
    required this.onAddExpenseTap,
    required this.formatCurrency,
  });

  final List<_CategoryExpenseEntry> entries;
  final VoidCallback onAddExpenseTap;
  final String Function(double value, {bool showSign}) formatCurrency;

  @override
  Widget build(BuildContext context) {
    const monthOrder = ['April', 'March', 'February'];

    return Column(
      children: [
        for (
          var monthIndex = 0;
          monthIndex < monthOrder.length;
          monthIndex++
        ) ...[
          Builder(
            builder: (context) {
              final month = monthOrder[monthIndex];
              final monthItems = entries
                  .where((item) => item.monthLabel == month)
                  .toList();
              if (monthItems.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Text(
                        month,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (monthIndex == 0)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMint,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final item in monthItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: _TransferTransactionRow(
                        icon: item.icon,
                        title: item.title,
                        dateLabel: item.timeDateLabel,
                        cadence: item.cadence,
                        amountLabel: formatCurrency(
                          -item.amount,
                          showSign: true,
                        ),
                        isExpense: true,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: onAddExpenseTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(118, 30),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Add Expenses',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _CategoryAddExpenseContent extends StatelessWidget {
  const _CategoryAddExpenseContent({
    required this.selectedCategory,
    required this.defaultTitle,
    required this.onSaveExpense,
  });

  final String selectedCategory;
  final String defaultTitle;
  final VoidCallback onSaveExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CategoryFormField(
          label: 'Date',
          value: 'March 3, 2023',
          trailingIcon: Icons.calendar_month_outlined,
        ),
        const SizedBox(height: 10),
        _CategoryFormField(
          label: 'Category',
          value: selectedCategory,
          trailingIcon: Icons.keyboard_arrow_down_rounded,
        ),
        const SizedBox(height: 10),
        const _CategoryFormField(label: 'Amount', value: '15.32'),
        const SizedBox(height: 10),
        _CategoryFormField(label: 'Expense Title', value: defaultTitle),
        const SizedBox(height: 10),
        const _CategoryMessageField(hintText: 'Error Message'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onSaveExpense,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(100, 30),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _CategoryFormField extends StatelessWidget {
  const _CategoryFormField({
    required this.label,
    required this.value,
    this.trailingIcon,
  });

  final String label;
  final String value;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.mintInput,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 15, color: AppColors.primaryMint),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryMessageField extends StatelessWidget {
  const _CategoryMessageField({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Optional Notes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.mintInput,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hintText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTopProgressBar extends StatelessWidget {
  const _CategoryTopProgressBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        color: Colors.white.withValues(alpha: 0.55),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.25,
            child: Container(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _DashboardProfileTab extends StatefulWidget {
  const _DashboardProfileTab();

  @override
  State<_DashboardProfileTab> createState() => _DashboardProfileTabState();
}

class _DashboardProfileTabState extends State<_DashboardProfileTab> {
  _ProfileFlowMode _mode = _ProfileFlowMode.menu;

  void _open(_ProfileFlowMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  void _goBack() {
    setState(() {
      switch (_mode) {
        case _ProfileFlowMode.menu:
          break;
        case _ProfileFlowMode.account:
          _mode = _ProfileFlowMode.menu;
        case _ProfileFlowMode.edit:
          _mode = _ProfileFlowMode.account;
        case _ProfileFlowMode.security:
          _mode = _ProfileFlowMode.menu;
        case _ProfileFlowMode.pinLock:
          _mode = _ProfileFlowMode.security;
        case _ProfileFlowMode.biometric:
          _mode = _ProfileFlowMode.security;
        case _ProfileFlowMode.terms:
          _mode = _ProfileFlowMode.menu;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_mode) {
      _ProfileFlowMode.menu => 'Profile',
      _ProfileFlowMode.account => 'Profile',
      _ProfileFlowMode.edit => 'Edit Profile',
      _ProfileFlowMode.security => 'Security',
      _ProfileFlowMode.pinLock => 'Pin Lock',
      _ProfileFlowMode.biometric => 'Biometric',
      _ProfileFlowMode.terms => 'Terms',
    };

    final showBack = _mode != _ProfileFlowMode.menu;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryMint,
          borderRadius: BorderRadius.circular(34),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: showBack ? _goBack : null,
                    borderRadius: BorderRadius.circular(999),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: showBack
                          ? AppColors.textPrimary
                          : AppColors.textPrimary.withValues(alpha: 0.75),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const _CircleActionIcon(
                    icon: Icons.notifications_none_rounded,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.mintSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(34),
                  bottomRight: Radius.circular(34),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: switch (_mode) {
                _ProfileFlowMode.menu => _ProfileMenuContent(
                  onMyAccountTap: () => _open(_ProfileFlowMode.account),
                  onSecurityTap: () => _open(_ProfileFlowMode.security),
                  onTermsTap: () => _open(_ProfileFlowMode.terms),
                ),
                _ProfileFlowMode.account => _ProfileAccountContent(
                  onEditTap: () => _open(_ProfileFlowMode.edit),
                ),
                _ProfileFlowMode.edit => _ProfileEditContent(
                  onSaveTap: _goBack,
                ),
                _ProfileFlowMode.security => _ProfileSecurityContent(
                  onPinTap: () => _open(_ProfileFlowMode.pinLock),
                  onBiometricTap: () => _open(_ProfileFlowMode.biometric),
                ),
                _ProfileFlowMode.pinLock => _ProfileActionDoneContent(
                  keyLabel: 'Pin lock enabled',
                  onAction: _goBack,
                ),
                _ProfileFlowMode.biometric => _ProfileActionDoneContent(
                  keyLabel: 'Biometric enabled',
                  onAction: _goBack,
                ),
                _ProfileFlowMode.terms => const _ProfileTermsContent(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuContent extends StatelessWidget {
  const _ProfileMenuContent({
    required this.onMyAccountTap,
    required this.onSecurityTap,
    required this.onTermsTap,
  });

  final VoidCallback onMyAccountTap;
  final VoidCallback onSecurityTap;
  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color(0xFF63B1FF).withValues(alpha: 0.3),
          child: const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF63B1FF),
            child: Icon(Icons.person, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Shahzaib User',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'shahzaib@finwise.app',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        _ProfileMenuTile(
          keyName: 'profile-tile-my-account',
          icon: Icons.person_outline_rounded,
          label: 'My Account',
          onTap: onMyAccountTap,
        ),
        _ProfileMenuTile(
          keyName: 'profile-tile-security',
          icon: Icons.lock_outline_rounded,
          label: 'Security',
          onTap: onSecurityTap,
        ),
        _ProfileMenuTile(
          keyName: 'profile-tile-terms',
          icon: Icons.description_outlined,
          label: 'Terms & Policies',
          onTap: onTermsTap,
        ),
        const _ProfileMenuTile(
          keyName: 'profile-tile-help',
          icon: Icons.help_outline_rounded,
          label: 'Help Center',
        ),
        const _ProfileMenuTile(
          keyName: 'profile-tile-invite',
          icon: Icons.group_add_outlined,
          label: 'Invite Friends',
        ),
        const _ProfileMenuTile(
          keyName: 'profile-tile-logout',
          icon: Icons.logout_rounded,
          label: 'Log Out',
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.keyName,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>(keyName),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAccountContent extends StatelessWidget {
  const _ProfileAccountContent({required this.onEditTap});

  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const CircleAvatar(
          radius: 34,
          backgroundColor: Color(0xFF63B1FF),
          child: Icon(Icons.person, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 10),
        const Text(
          'Shahzaib User',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _ProfileInfoRow(label: 'Name', value: 'Shahzaib User'),
        const _ProfileInfoRow(label: 'Email', value: 'shahzaib@finwise.app'),
        const _ProfileInfoRow(label: 'Phone', value: '+92 300 1234567'),
        const _ProfileInfoRow(label: 'Address', value: 'Lahore, Pakistan'),
        const SizedBox(height: 12),
        ElevatedButton(
          key: const ValueKey<String>('profile-edit-button'),
          onPressed: onEditTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(110, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.mintInput,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditContent extends StatelessWidget {
  const _ProfileEditContent({required this.onSaveTap});

  final VoidCallback onSaveTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CategoryFormField(label: 'Name', value: 'Shahzaib User'),
        const SizedBox(height: 10),
        const _CategoryFormField(label: 'Username', value: 'shahzaib_finwise'),
        const SizedBox(height: 10),
        const _CategoryFormField(label: 'Email', value: 'shahzaib@finwise.app'),
        const SizedBox(height: 10),
        const _CategoryFormField(label: 'Phone', value: '+92 300 1234567'),
        const SizedBox(height: 10),
        const _CategoryMessageField(hintText: 'Bio or status message'),
        const SizedBox(height: 12),
        ElevatedButton(
          key: const ValueKey<String>('profile-save-button'),
          onPressed: onSaveTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(88, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Save',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ProfileSecurityContent extends StatelessWidget {
  const _ProfileSecurityContent({
    required this.onPinTap,
    required this.onBiometricTap,
  });

  final VoidCallback onPinTap;
  final VoidCallback onBiometricTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileMenuTile(
          keyName: 'profile-tile-pin',
          icon: Icons.pin_outlined,
          label: 'Pin Lock',
          onTap: onPinTap,
        ),
        _ProfileMenuTile(
          keyName: 'profile-tile-biometric',
          icon: Icons.fingerprint,
          label: 'Biometric',
          onTap: onBiometricTap,
        ),
        const _ProfileMenuTile(
          keyName: 'profile-tile-password',
          icon: Icons.lock_reset_outlined,
          label: 'Change Password',
        ),
        const _ProfileMenuTile(
          keyName: 'profile-tile-two-factor',
          icon: Icons.shield_outlined,
          label: 'Two-Factor Authentication',
        ),
      ],
    );
  }
}

class _ProfileActionDoneContent extends StatelessWidget {
  const _ProfileActionDoneContent({
    required this.keyLabel,
    required this.onAction,
  });

  final String keyLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryMint.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.primaryMint, width: 2),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.primaryMint,
            size: 52,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          keyLabel,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          key: const ValueKey<String>('profile-done-button'),
          onPressed: onAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMint,
            foregroundColor: AppColors.textPrimary,
            minimumSize: const Size(82, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Done',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ProfileTermsContent extends StatelessWidget {
  const _ProfileTermsContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.mintInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'By using FinWise, you agree to keep your account credentials secure and use the app responsibly.\n\nData shown in this prototype is demo data for UI practice. In production, personal and financial data should be encrypted, protected by authentication, and handled according to privacy regulations.\n\nYou can update your profile and security preferences at any time from this section.',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AnalysisSearchPanel extends StatelessWidget {
  const _AnalysisSearchPanel({
    required this.transactions,
    required this.runSearch,
    required this.showResult,
    required this.formatCurrency,
  });

  final List<ExpenseItem> transactions;
  final VoidCallback runSearch;
  final bool showResult;
  final String Function(double value, {bool showSign}) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final result = transactions
        .where((item) => item.type == EntryType.expense)
        .first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mintInput.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const _SearchField(label: 'Categories', value: 'Select the category'),
          const SizedBox(height: 8),
          const _SearchField(label: 'Date', value: '30 / Apr / 2023'),
          const SizedBox(height: 8),
          const Text(
            'Report',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              _ReportDot(label: 'Income'),
              SizedBox(width: 20),
              _ReportDot(label: 'Expense', active: true),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: runSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMint,
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size(90, 30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
              ),
              child: const Text('Search'),
            ),
          ),
          if (showResult) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF63B1FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.shopping_basket_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    formatCurrency(-result.amount, showSign: true),
                    style: const TextStyle(
                      color: Color(0xFF176BFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.mintInput,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.primaryMint,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportDot extends StatelessWidget {
  const _ReportDot({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle : Icons.circle_outlined,
          size: 12,
          color: active ? AppColors.primaryMint : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AnalysisChartCard extends StatelessWidget {
  const _AnalysisChartCard({
    required this.snapshot,
    required this.formatCurrency,
  });

  final _AnalysisSnapshot snapshot;
  final String Function(double value, {bool showSign}) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.mintInput.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Income & Expenses',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              _CircleActionIcon(
                icon: Icons.stacked_line_chart_rounded,
                compact: true,
              ),
              SizedBox(width: 4),
              _CircleActionIcon(
                icon: Icons.insert_chart_outlined_rounded,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(height: 132, child: _AnalysisBarChart(snapshot: snapshot)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _IncomeExpenseTotal(
                  label: 'Income',
                  value: formatCurrency(snapshot.income),
                  icon: Icons.north_east_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _IncomeExpenseTotal(
                  label: 'Expense',
                  value: formatCurrency(-snapshot.expense, showSign: true),
                  icon: Icons.south_east_rounded,
                  expense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalysisBarChart extends StatelessWidget {
  const _AnalysisBarChart({required this.snapshot});

  final _AnalysisSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < snapshot.labels.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ChartBar(height: 68 * snapshot.incomeBars[i], income: true),
                  const SizedBox(height: 2),
                  _ChartBar(
                    height: 68 * snapshot.expenseBars[i],
                    income: false,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    snapshot.labels[i],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({required this.height, required this.income});

  final double height;
  final bool income;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: income ? AppColors.primaryMint : const Color(0xFF176BFF),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _IncomeExpenseTotal extends StatelessWidget {
  const _IncomeExpenseTotal({
    required this.label,
    required this.value,
    required this.icon,
    this.expense = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: expense ? const Color(0xFF176BFF) : AppColors.primaryMint,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: expense
                        ? const Color(0xFF176BFF)
                        : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisTopProgressBar extends StatelessWidget {
  const _AnalysisTopProgressBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        color: Colors.white.withValues(alpha: 0.55),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.38,
            child: Container(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _AnalysisPeriodChip extends StatelessWidget {
  const _AnalysisPeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryMint : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.title,
    required this.value,
    required this.valueColor,
    this.alignEnd = false,
  });

  final String title;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary.withValues(alpha: 0.88),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetProgressBar extends StatelessWidget {
  const _BudgetProgressBar({required this.progress, required this.capLabel});

  final double progress;
  final String capLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 25,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final clamped = progress.clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(color: Colors.white.withValues(alpha: 0.84)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: constraints.maxWidth * clamped,
                    color: AppColors.mintDark,
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          '${(clamped * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          capLabel,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SavingsInsightCard extends StatelessWidget {
  const _SavingsInsightCard({
    required this.revenueLabel,
    required this.foodLabel,
  });

  final String revenueLabel;
  final String foodLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryMint,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              children: [
                SizedBox(height: 2),
                _GoalIcon(),
                SizedBox(height: 8),
                Text(
                  'Savings\nOn Goals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 78,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  _InsightMetricRow(
                    icon: Icons.layers_outlined,
                    title: 'Revenue Last Week',
                    value: revenueLabel,
                  ),
                  const Divider(height: 12, color: Colors.white70),
                  _InsightMetricRow(
                    icon: Icons.restaurant_outlined,
                    title: 'Food Last Week',
                    value: foodLabel,
                    isExpense: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalIcon extends StatelessWidget {
  const _GoalIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1B6AFE), width: 2),
          ),
        ),
        const Icon(
          Icons.directions_car_outlined,
          size: 26,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}

class _InsightMetricRow extends StatelessWidget {
  const _InsightMetricRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isExpense = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isExpense ? const Color(0xFF176BFF) : Colors.black,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomePeriodSelector extends StatelessWidget {
  const _HomePeriodSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mintInput,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(4),
      child: const Row(
        children: [
          Expanded(child: _HomePeriodChip(label: 'Daily')),
          Expanded(child: _HomePeriodChip(label: 'Weekly')),
          Expanded(child: _HomePeriodChip(label: 'Monthly', isSelected: true)),
        ],
      ),
    );
  }
}

class _HomePeriodChip extends StatelessWidget {
  const _HomePeriodChip({required this.label, this.isSelected = false});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryMint : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DashboardTransactionRow extends StatelessWidget {
  const _DashboardTransactionRow({
    required this.icon,
    required this.title,
    required this.dateLabel,
    required this.cadence,
    required this.amountLabel,
    required this.isExpense,
  });

  final IconData icon;
  final String title;
  final String dateLabel;
  final String cadence;
  final String amountLabel;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF63B1FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, size: 22, color: Colors.white),
        ),
        const SizedBox(width: 11),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: Color(0xFF176BFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 38,
          color: AppColors.primaryMint.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            cadence,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 38,
          color: AppColors.primaryMint.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            amountLabel,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isExpense
                  ? const Color(0xFF176BFF)
                  : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleActionIcon extends StatelessWidget {
  const _CircleActionIcon({
    required this.icon,
    this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 24.0 : 34.0;
    final iconSize = compact ? 14.0 : 18.0;
    final child = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.mintDark.withValues(alpha: 0.34)),
        color: Colors.white.withValues(alpha: 0.14),
      ),
      child: Icon(icon, size: iconSize, color: AppColors.mintDark),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: child,
    );
  }
}

class _FixedBottomNavigation extends StatelessWidget {
  const _FixedBottomNavigation({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      Icons.home_outlined,
      Icons.analytics_outlined,
      Icons.compare_arrows_rounded,
      Icons.layers_outlined,
      Icons.person_outline_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mintInput,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final selected = index == selectedIndex;
          return InkWell(
            key: ValueKey<String>('bottom-nav-$index'),
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryMint : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(items[index], color: AppColors.textPrimary, size: 22),
            ),
          );
        }),
      ),
    );
  }
}
