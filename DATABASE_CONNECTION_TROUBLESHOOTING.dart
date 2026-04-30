// TROUBLESHOOTING GUIDE: Database Connection Issues

1. **Check These Things First**

   a) Verify Firebase is initialized in main.dart:
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();  // ✅ This MUST complete
     runApp(const ExpenseTracingApp());
   }
   ```

   b) Check Console Logs for errors:
      - Look for 🔄, ✅, ❌, 💰, 💳 emoji markers
      - Check for "Error" messages from services

   c) Verify Firestore Security Rules:
      - Go to Firebase Console > Firestore > Rules
      - Rules must allow authenticated users to read/write to /users/{uid}/*
      - Default rules may DENY everything

   d) Verify Authentication:
      - Users must be logged in before data appears
      - Check if currentUserId is valid (not null)

---

2. **If Data Still Doesn't Load**

   Add this to your main.dart for debugging:
   ```dart
   import 'package:expence_tracking/services/firebase_status_service.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     
     // Debug Firebase status
     FirebaseStatusService.printStatus();
     
     runApp(const ExpenseTracingApp());
   }
   ```

   This will print status information to the console.

---

3. **Common Issues and Solutions**

   Issue: "No data appears on dashboard"
   - Solution: Check if user is logged in (email shown in auth)
   - Check console for ❌ error messages
   - Verify Firestore rules allow access

   Issue: "Stream shows 0 items but data was added"
   - Solution: Check Firebase Console > Firestore
   - Verify data is saved in correct path: /users/{userId}/expenses
   - Check Firestore indexes (might be required)

   Issue: "getStorage() called but instance not initialized"
   - Solution: Ensure Firebase.initializeApp() completes before runApp()
   - Add WidgetsFlutterBinding.ensureInitialized() before Firebase init

---

4. **Firestore Indexes**
   
   If you see "Query error: could not find a suitable index", add index in Firebase Console:
   - Collection: users/{userId}/expenses
   - Fields: date (Descending)

---

5. **Testing the Connection**

   a) Add test data manually in Firebase Console:
      - Navigate to /users/{yourUserId}/expenses
      - Click Add document
      - Add a test expense record
      - Refresh app - data should appear

   b) Check Dashboard Provider logs:
      - When user logs in, you should see:
        "🔄 DashboardProvider.setUser called with userId: xxxxx"
        "✅ Subscribing to salary stream"
        "✅ Subscribing to expense stream"
        "💳 Received N expenses"

