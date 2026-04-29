import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expence_tracking/app/app_routes.dart';
import 'package:expence_tracking/app/app_theme.dart';
import 'package:expence_tracking/features/auth/auth_provider.dart';
import 'package:expence_tracking/shared/widgets/pill_button.dart';
import 'package:expence_tracking/shared/widgets/rounded_input_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value!)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final requiredResult = _requiredValidator(value);
    if (requiredResult != null) {
      return requiredResult;
    }
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredResult = _requiredValidator(value);
    if (requiredResult != null) {
      return requiredResult;
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _onSignupPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signup(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      dateOfBirth: _dateController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    } else {
      // Show error message from backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.lastErrorMessage ?? 'Signup failed'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryMint,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text(
                'Create Account',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.mintSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
                ),
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RoundedInputField(
                        label: 'Full Name',
                        hintText: 'John Doe',
                        controller: _nameController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      RoundedInputField(
                        label: 'Email',
                        hintText: 'example@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 10),
                      RoundedInputField(
                        label: 'Mobile Number',
                        hintText: '+92 300 1234567',
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      RoundedInputField(
                        label: 'Date Of Birth',
                        hintText: 'DD / MM / YYYY',
                        controller: _dateController,
                        validator: _requiredValidator,
                      ),
                      const SizedBox(height: 10),
                      RoundedInputField(
                        label: 'Password',
                        hintText: '********',
                        controller: _passwordController,
                        obscurable: true,
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: 10),
                      RoundedInputField(
                        label: 'Confirm Password',
                        hintText: '********',
                        controller: _confirmPasswordController,
                        obscurable: true,
                        validator: _confirmPasswordValidator,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'By continuing, you agree to\nTerms of Use and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PillButton(
                        label: _isLoading ? 'Creating Account...' : 'Sign Up',
                        onPressed: _isLoading ? null : _onSignupPressed,
                        width: 180,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: const Text(
                              'Log In',
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