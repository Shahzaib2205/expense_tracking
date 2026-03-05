import 'package:flutter/material.dart';

import 'package:expence_tracking/app/app_routes.dart';
import 'package:expence_tracking/app/app_theme.dart';
import 'package:expence_tracking/shared/widgets/pill_button.dart';
import 'package:expence_tracking/shared/widgets/rounded_input_field.dart';
import 'package:expence_tracking/shared/widgets/social_icon_row.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  void _onNextStepPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset link sent to your email.')),
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
                'Forgot Password',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 66),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.mintSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
                ),
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Reset Password?',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do\neiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),
                      RoundedInputField(
                        label: 'Enter Email Address',
                        hintText: 'example@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 22),
                      PillButton(
                        label: 'Next Step',
                        onPressed: _onNextStepPressed,
                        width: 130,
                      ),
                      const SizedBox(height: 24),
                      PillButton(
                        label: 'Sign Up',
                        isPrimary: false,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        width: 170,
                      ),
                      const SizedBox(height: 14),
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
