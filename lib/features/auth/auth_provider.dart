import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expence_tracking/backend/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  String? _currentUserEmail;
  String? _lastErrorMessage;
  late final _authSub = _authService.authStateChanges.listen((user) {
    _isAuthenticated = user != null;
    _currentUserEmail = user?.email;
    if (!_isAuthenticated) {
      _lastErrorMessage = null;
    }
    notifyListeners();
  });

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;
  String? get lastErrorMessage => _lastErrorMessage;

  // Signup method with proper error handling
  Future<bool> signup({
    required String fullName,
    required String email,
    required String mobile,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
  }) async {
    // Call backend service
    final result = await _authService.signup(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (result.success) {
      _isAuthenticated = true;
      _currentUserEmail = email;
      // Notify dashboard of new user id
      notifyListeners();
      _lastErrorMessage = null;
      notifyListeners();
      return true;
    } else {
      _lastErrorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  // Login method with proper error handling
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Call backend service
    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result.success) {
      _isAuthenticated = true;
      _currentUserEmail = email;
      _lastErrorMessage = null;
      notifyListeners();
      return true;
    } else {
      _lastErrorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _currentUserEmail = null;
    _lastErrorMessage = null;
    _authService.signOut();
    notifyListeners();
  }

  void clearError() {
    _lastErrorMessage = null;
    notifyListeners();
  }
  
  // For debugging - get total users
  int getTotalUsers() {
    return _authService.getUserCount();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}