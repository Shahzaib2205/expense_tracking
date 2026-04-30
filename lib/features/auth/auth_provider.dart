import 'package:flutter/foundation.dart';
import 'package:expence_tracking/backend/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  String? _currentUserId;
  String? _currentUserEmail;
  String? _lastErrorMessage;
  late final _authSub = _authService.authStateChanges.listen((user) {
    _isAuthenticated = user != null;
    _currentUserId = user?.uid;
    _currentUserEmail = user?.email;
    if (!_isAuthenticated) {
      _lastErrorMessage = null;
    }
    notifyListeners();
  });

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
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
      _currentUserId = _authService.getCurrentUserId();
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
      _currentUserId = _authService.getCurrentUserId();
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
    _currentUserId = null;
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