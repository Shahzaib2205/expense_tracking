import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence_tracking/app/app_routes.dart';
import 'package:expence_tracking/app/app_theme.dart';
import 'package:expence_tracking/features/auth/auth_provider.dart';
import 'package:expence_tracking/shared/widgets/pill_button.dart';
import 'package:expence_tracking/shared/widgets/rounded_input_field.dart';
import 'package:expence_tracking/shared/widgets/social_icon_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredResult = _requiredValidator(value);
    if (requiredResult != null) {
      return requiredResult;
    }
    if (!value!.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!authProvider.isAuthenticated) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryMint,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 72),
              const Text(
                'Welcome',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 68),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.mintSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
                ),
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RoundedInputField(
                        label: 'Username Or Email',
                        hintText: 'example@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 12),
                      RoundedInputField(
                        label: 'Password',
                        hintText: '********',
                        controller: _passwordController,
                        obscurable: true,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 22),
                      PillButton(
                        label: 'Log In',
                        onPressed: _onLoginPressed,
                        width: 170,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Forgot Password?'),
                      ),
                      const SizedBox(height: 2),
                      PillButton(
                        label: 'Sign Up',
                        isPrimary: false,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        width: 170,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Use Fingerprint To Access',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SocialIconRow(caption: 'or sign up with'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.signup);
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primaryMint,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
