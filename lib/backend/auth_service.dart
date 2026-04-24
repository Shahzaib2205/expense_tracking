import 'package:flutter/foundation.dart';

class AuthService {
  // ==================================================
  // STATIC DATA STORAGE (Array/Object - No Database)
  // WITH DEFAULT TEST USER
  // ==================================================
  
  // Static list to store all users (array of objects)
  static final List<Map<String, dynamic>> _usersList = [
    {
      'email': 'shahzaib@gmail.com',
      'password': '123456',
      'fullName': 'Shahzaib',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];
  
  // Helper method to find user by email
  Map<String, dynamic>? _findUserByEmail(String email) {
    try {
      return _usersList.firstWhere(
        (user) => user['email'].toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  // Helper method to check if email already exists
  bool _isEmailExists(String email) {
    return _findUserByEmail(email) != null;
  }

  // Email validation using regex
  bool _isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation (min 6 characters)
  bool _isValidPassword(String password) {
    if (password.isEmpty) return false;
    if (password.length < 6) return false;
    return true;
  }
  
  // Check if any field is empty (for signup)
  bool _hasEmptyFields({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return email.trim().isEmpty || 
           password.isEmpty || 
           confirmPassword.isEmpty;
  }
  
  // Check if any field is empty (for login)
  bool _hasEmptyLoginFields({
    required String email,
    required String password,
  }) {
    return email.trim().isEmpty || password.isEmpty;
  }

  // ==================================================
  // SIGNUP METHOD WITH SWITCH STATEMENT
  // ==================================================
  
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Switch statement for validation
    switch (true) {
      // Case 1: Empty fields
      case true when _hasEmptyFields(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      ):
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.emptyFields,
          message: 'All fields are required',
        );

      // Case 2: Invalid email format
      case true when !_isValidEmail(email):
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.invalidEmail,
          message: 'Please enter a valid email address',
        );

      // Case 3: Weak password (less than 6 characters)
      case true when !_isValidPassword(password):
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.weakPassword,
          message: 'Password must be at least 6 characters long',
        );

      // Case 4: Password and confirm password don't match
      case true when password != confirmPassword:
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.passwordMismatch,
          message: 'Password and Confirm Password do not match',
        );

      // Case 5: User already exists
      case true when _isEmailExists(email):
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.userAlreadyExists,
          message: 'An account with this email already exists. Please login.',
        );

      // Case 6: Success - All validations passed
      default:
        // Store user data in static list (array/object storage)
        final newUser = {
          'email': email.toLowerCase(),
          'password': password,
          'fullName': email.split('@')[0],
          'createdAt': DateTime.now().toIso8601String(),
        };
        
        // Add to static list storage
        _usersList.add(newUser);
        
        debugPrint('User stored successfully. Total users: ${_usersList.length}');
        debugPrint('Users list: $_usersList');
        
        return const AuthResult(
          success: true,
          errorCode: AuthErrorCode.none,
          message: 'Account created successfully',
        );
    }
  }

  // ==================================================
  // LOGIN METHOD WITH SWITCH STATEMENT
  // ==================================================
  
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Switch statement for validation
    switch (true) {
      // Case 1: Empty fields
      case true when _hasEmptyLoginFields(email: email, password: password):
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.emptyFields,
          message: 'Email and Password are required',
        );

      // Case 2: Invalid email format
      case true when !_isValidEmail(email):
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.invalidEmail,
          message: 'Please enter a valid email address',
        );

      // Case 3: User not found
      case true when !_isEmailExists(email):
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.userNotFound,
          message: 'No account found with this email. Please sign up first.',
        );

      // Case 4: Wrong password
      case true when _findUserByEmail(email)!['password'] != password:
        return const AuthResult(
          success: false,
          errorCode: AuthErrorCode.wrongPassword,
          message: 'Incorrect password. Please try again.',
        );

      // Case 5: Success - Valid credentials
      default:
        return const AuthResult(
          success: true,
          errorCode: AuthErrorCode.none,
          message: 'Login successful',
        );
    }
  }

  // ==================================================
  // HELPER METHODS (For Testing/Debugging)
  // ==================================================
  
  // Get all users (for debugging)
  List<Map<String, dynamic>> getAllUsers() {
    return List.unmodifiable(_usersList);
  }
  
  // Get total user count
  int getUserCount() {
    return _usersList.length;
  }
  
  // Clear all users (for testing)
  void clearAllUsers() {
    _usersList.clear();
    debugPrint('All users cleared. Total users: ${_usersList.length}');
  }
  
  // Add default test user (optional)
  void addDefaultTestUser() {
    if (!_isEmailExists('shahzaib@gmail.com')) {
      _usersList.add({
        'email': 'shahzaib@gmail.com',
        'password': '123456',
        'fullName': 'Shahzaib',
        'createdAt': DateTime.now().toIso8601String(),
      });
      debugPrint('Default test user added');
    }
  }
}

// ==================================================
// ERROR CODES ENUM
// ==================================================

enum AuthErrorCode {
  none,
  emptyFields,
  invalidEmail,
  weakPassword,
  passwordMismatch,
  userAlreadyExists,
  userNotFound,
  wrongPassword,
}

// ==================================================
// AUTH RESULT CLASS
// ==================================================

class AuthResult {
  final bool success;
  final AuthErrorCode errorCode;
  final String message;

  const AuthResult({
    required this.success,
    required this.errorCode,
    required this.message,
  });
}