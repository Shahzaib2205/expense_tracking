import 'package:flutter/material.dart';

import 'package:expence_tracking/features/auth/forgot_password_screen.dart';
import 'package:expence_tracking/features/auth/login_screen.dart';
import 'package:expence_tracking/features/auth/signup_screen.dart';
import 'package:expence_tracking/features/dashboard/dashboard_screen.dart';
import 'package:expence_tracking/features/launch/auth_landing_screen.dart';
import 'package:expence_tracking/features/launch/launch_splash_screen.dart';

class AppRoutes {
  static const String launchSplash = '/launch-splash';
  static const String authLanding = '/auth-landing';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case launchSplash:
        return MaterialPageRoute<void>(
          builder: (_) => const LaunchSplashScreen(),
        );
      case authLanding:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthLandingScreen(),
        );
      case login:
        return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute<void>(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute<void>(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case dashboard:
        return MaterialPageRoute<void>(builder: (_) => const DashboardScreen());
      default:
        return MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  const AppRoutes._();
}
