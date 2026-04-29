import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  factory AuthService() => instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.trim().isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return const AuthResult(
        success: false,
        errorCode: AuthErrorCode.emptyFields,
        message: 'All fields are required',
      );
    }

    if (password != confirmPassword) {
      return const AuthResult(
        success: false,
        errorCode: AuthErrorCode.passwordMismatch,
        message: 'Password and Confirm Password do not match',
      );
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(email.split('@').first);
      await cred.user?.reload();
      return const AuthResult(success: true, errorCode: AuthErrorCode.none, message: 'Account created successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorCode: _mapErrorCode(e.code), message: e.message ?? 'Authentication error');
    } catch (e) {
      return AuthResult(success: false, errorCode: AuthErrorCode.unknown, message: 'Unexpected error during registration: $e');
    }
  }

  /// Returns 1 if a user is currently signed in, otherwise 0.
  int getUserCount() {
    return _auth.currentUser == null ? 0 : 1;
  }

  String? getCurrentUserId() => _auth.currentUser?.uid;

  Future<AuthResult> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const AuthResult(success: false, errorCode: AuthErrorCode.emptyFields, message: 'Email and Password are required');
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return const AuthResult(success: true, errorCode: AuthErrorCode.none, message: 'Login successful');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorCode: _mapErrorCode(e.code), message: e.message ?? 'Authentication error');
    } catch (e) {
      return AuthResult(success: false, errorCode: AuthErrorCode.unknown, message: 'Unexpected error during sign-in: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      return const AuthResult(success: false, errorCode: AuthErrorCode.emptyFields, message: 'Email is required');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true, errorCode: AuthErrorCode.none, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorCode: _mapErrorCode(e.code), message: e.message ?? 'Failed to send password reset email');
    } catch (e) {
      return AuthResult(success: false, errorCode: AuthErrorCode.unknown, message: 'Unexpected error while sending reset email: $e');
    }
  }

  AuthErrorCode _mapErrorCode(String code) {
    switch (code) {
      case 'weak-password':
        return AuthErrorCode.weakPassword;
      case 'email-already-in-use':
        return AuthErrorCode.userAlreadyExists;
      case 'invalid-email':
        return AuthErrorCode.invalidEmail;
      case 'user-not-found':
        return AuthErrorCode.userNotFound;
      case 'wrong-password':
        return AuthErrorCode.wrongPassword;
      case 'too-many-requests':
        return AuthErrorCode.tooManyRequests;
      case 'invalid-credential':
        return AuthErrorCode.invalidCredential;
      case 'invalid-login-credentials':
        return AuthErrorCode.invalidCredential;
      case 'operation-not-allowed':
        return AuthErrorCode.operationNotAllowed;
      case 'network-request-failed':
        return AuthErrorCode.networkError;
      default:
        return AuthErrorCode.unknown;
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
  tooManyRequests,
  invalidCredential,
  operationNotAllowed,
  networkError,
  unknown,
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