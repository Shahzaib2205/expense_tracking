import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence_tracking/app/app_routes.dart';
import 'package:expence_tracking/app/app_theme.dart';
import 'package:expence_tracking/features/auth/auth_provider.dart';
import 'package:expence_tracking/backend/auth_service.dart';
import 'package:expence_tracking/features/dashboard/dashboard_provider.dart';

class ExpenseTracingApp extends StatelessWidget {
  const ExpenseTracingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FinWise',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.launchSplash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
