import 'package:firebase_database/firebase_database.dart';

class RealtimeDbService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference _userBalanceRef(String uid) => _db.ref('users/$uid/balance');

  Stream<double> streamBalance({required String userId}) {
    try {
      return _userBalanceRef(userId).onValue.map((event) {
        try {
          final val = event.snapshot.value;
          if (val == null) return 0.0;
          if (val is num) return val.toDouble();
          return double.tryParse(val.toString()) ?? 0.0;
        } catch (e) {
          print('Error parsing balance value: $e');
          return 0.0;
        }
      }).handleError((e) {
        print('Error in streamBalance: $e');
      });
    } catch (e) {
      print('Error creating balance stream: $e');
      return Stream.value(0.0);
    }
  }

  Future<double> getBalanceOnce({required String userId}) async {
    try {
      final snap = await _userBalanceRef(userId).get();
      final val = snap.value;
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    } catch (e) {
      print('Error getting balance: $e');
      return 0.0;
    }
  }

  Future<void> incrementBalance({required String userId, required double delta}) async {
    try {
      // Note: prefer a database transaction for atomic increments. Using
      // a get/set here for simplicity and compatibility with current SDK types.
      final ref = _userBalanceRef(userId);
      final snap = await ref.get();
      double curr = 0.0;
      if (snap.value != null) {
        final val = snap.value;
        if (val is num) {
          curr = val.toDouble();
        } else {
          curr = double.tryParse(val.toString()) ?? 0.0;
        }
      }
      await ref.set(curr + delta);
    } catch (e) {
      print('Error incrementing balance: $e');
      rethrow;
    }
  }
}
