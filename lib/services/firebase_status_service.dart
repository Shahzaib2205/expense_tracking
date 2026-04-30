import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility service to check Firebase connectivity and configuration
class FirebaseStatusService {
  static Future<Map<String, dynamic>> getStatus() async {
    final status = <String, dynamic>{};

    try {
      // Check Firebase Core
      status['firebase_initialized'] = true;
      print('✅ Firebase Core initialized');
    } catch (e) {
      status['firebase_initialized'] = false;
      status['firebase_error'] = e.toString();
      print('❌ Firebase not initialized: $e');
    }

    try {
      // Check Auth
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      status['auth_initialized'] = true;
      status['user_logged_in'] = currentUser != null;
      status['current_user_id'] = currentUser?.uid;
      status['current_user_email'] = currentUser?.email;
      print('✅ Firebase Auth status: ${currentUser != null ? "User logged in (${currentUser.uid})" : "No user"}');
    } catch (e) {
      status['auth_error'] = e.toString();
      print('❌ Firebase Auth error: $e');
    }

    try {
      // Check Firestore
      final firestore = FirebaseFirestore.instance;
      // Try to get a test document
      final testDoc = await firestore.collection('_system').doc('test').get();
      status['firestore_initialized'] = true;
      status['firestore_accessible'] = true;
      print('✅ Firestore accessible');
    } catch (e) {
      status['firestore_error'] = e.toString();
      print('⚠️ Firestore error: $e');
    }

    return status;
  }

  static void printStatus() {
    getStatus().then((status) {
      print('\n=== Firebase Status ===');
      status.forEach((key, value) {
        print('$key: $value');
      });
      print('======================\n');
    });
  }
}
