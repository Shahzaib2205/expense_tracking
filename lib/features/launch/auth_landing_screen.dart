import 'package:flutter/material.dart';

import 'package:expence_tracking/app/app_routes.dart';
import 'package:expence_tracking/app/app_theme.dart';
import 'package:expence_tracking/shared/widgets/app_logo.dart';
import 'package:expence_tracking/shared/widgets/pill_button.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mintSurface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(
                    iconColor: AppColors.primaryMint,
                    textColor: AppColors.primaryMint,
                    iconSize: 84,
                    fontSize: 42,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur\nadipisicing elit, sed do eiusmod.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 26),
                  PillButton(
                    label: 'Log In',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    width: 190,
                  ),
                  const SizedBox(height: 10),
                  PillButton(
                    label: 'Sign Up',
                    isPrimary: false,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.signup);
                    },
                    width: 190,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
