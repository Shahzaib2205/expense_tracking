import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void login({required String email, required String password}) {
    _isAuthenticated = email.isNotEmpty && password.isNotEmpty;
    notifyListeners();
  }

  void signup({
    required String fullName,
    required String email,
    required String mobile,
    required String dateOfBirth,
    required String password,
  }) {
    final allFilled =
        fullName.isNotEmpty &&
        email.isNotEmpty &&
        mobile.isNotEmpty &&
        dateOfBirth.isNotEmpty &&
        password.isNotEmpty;
    _isAuthenticated = allFilled;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
