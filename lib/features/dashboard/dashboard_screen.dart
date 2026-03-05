import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence_tracking/app/app_routes.dart';
import 'package:expence_tracking/app/app_theme.dart';
import 'package:expence_tracking/features/auth/auth_provider.dart';
import 'package:expence_tracking/features/dashboard/dashboard_provider.dart';
import 'package:expence_tracking/features/dashboard/widgets/dashboard_section_card.dart';
import 'package:expence_tracking/features/dashboard/widgets/summary_metric_card.dart';
import 'package:expence_tracking/models/expense_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _currency(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinWise Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.authLanding,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryMint,
        foregroundColor: AppColors.textPrimary,
        onPressed: () {
          context.read<DashboardProvider>().quickAddExpense();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Quick Add Expense',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          final categoryEntries = dashboard.categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final highestCategoryValue = categoryEntries.isEmpty
              ? 1.0
              : categoryEntries.first.value;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryMint, Color(0xFF0AB794)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currency(dashboard.balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SummaryMetricCard(
                                title: 'Monthly Income',
                                value: _currency(dashboard.totalIncome),
                                isExpense: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SummaryMetricCard(
                                title: 'Monthly Expense',
                                value: _currency(dashboard.totalExpense),
                                isExpense: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const DashboardSectionCard(
                    title: 'Monthly Income vs Expense',
                    child: _MiniChartPlaceholder(),
                  ),
                  const SizedBox(height: 14),
                  DashboardSectionCard(
                    title: 'Category Breakdown',
                    child: categoryEntries.isEmpty
                        ? const Text('No expense categories yet.')
                        : Column(
                            children: [
                              for (final entry in categoryEntries)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            entry.key,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _currency(entry.value),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        child: LinearProgressIndicator(
                                          minHeight: 8,
                                          value:
                                              entry.value /
                                              highestCategoryValue,
                                          backgroundColor: AppColors.mintInput,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                AppColors.primaryMint,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 14),
                  DashboardSectionCard(
                    title: 'Recent Transactions',
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('See all'),
                    ),
                    child: Column(
                      children: [
                        for (final item in dashboard.recentTransactions)
                          _TransactionTile(
                            title: item.title,
                            subtitle:
                                '${item.category} • ${_dateLabel(item.date)}',
                            value:
                                '${item.type == EntryType.expense ? '-' : '+'}${_currency(item.amount)}',
                            isExpense: item.type == EntryType.expense,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniChartPlaceholder extends StatelessWidget {
  const _MiniChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    const incomeBars = [0.35, 0.5, 0.72, 0.6, 0.8, 0.68, 0.88];
    const expenseBars = [0.22, 0.4, 0.5, 0.42, 0.6, 0.48, 0.55];
    const maxBarHeight = 72.0;

    return Column(
      children: [
        SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < incomeBars.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _Bar(
                          height: maxBarHeight * incomeBars[i],
                          isIncome: true,
                        ),
                        const SizedBox(height: 3),
                        _Bar(
                          height: maxBarHeight * expenseBars[i],
                          isIncome: false,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(label: 'Income', color: AppColors.primaryMint),
            SizedBox(width: 14),
            _LegendDot(label: 'Expense', color: AppColors.mintDark),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.isIncome});

  final double height;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: isIncome ? AppColors.primaryMint : AppColors.mintDark,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isExpense,
  });

  final String title;
  final String subtitle;
  final String value;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mintInput.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isExpense
                  ? AppColors.mintDark.withValues(alpha: 0.18)
                  : AppColors.primaryMint.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense ? Icons.call_made_rounded : Icons.call_received_rounded,
              size: 18,
              color: isExpense ? AppColors.mintDark : AppColors.primaryMint,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isExpense ? Colors.red.shade400 : Colors.green.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
