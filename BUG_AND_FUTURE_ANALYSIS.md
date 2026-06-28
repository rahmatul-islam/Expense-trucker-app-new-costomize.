# Expense Tracker - Bug Analysis & Future Improvements

## 🐛 CRITICAL BUGS

### 1. **Security Issue: Plain Text Password Storage**
**File:** [lib/database/database_helper.dart](lib/database/database_helper.dart#L86)
- Passwords are stored in plain text in the database
- **Fix:** Implement bcrypt or SHA-256 hashing
```dart
// Instead of:
await database.insert('users', {'email': email, 'password': password});

// Use:
import 'package:crypto/crypto.dart';
String hashedPassword = sha256.convert(utf8.encode(password)).toString();
```

### 2. **No Email Uniqueness Constraint**
**File:** [lib/database/database_helper.dart](lib/database/database_helper.dart#L14)
- Users can sign up multiple times with the same email
- **Fix:** Add UNIQUE constraint to users table
```dart
await db.execute('''
  CREATE TABLE users(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
  )
''');
```

### 3. **No Input Validation for Negative Amounts**
**File:** [lib/screens/add_expense.dart](lib/screens/add_expense.dart#L356)
- Allows negative expense amounts
- **Fix:** Add validation
```dart
final amount = int.tryParse(amountText);
if (amount == null || amount <= 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Amount must be greater than 0"))
  );
  return;
}
```

### 4. **Account Balance Calculation Bug**
**File:** [lib/database/database_helper.dart](lib/database/database_helper.dart#L158)
- Income increases balance, Expense decreases - but this is confusing for multiple transactions
- CSV export shows incorrect balance calculation
- **Fix:** Track account transactions separately or clarify logic

### 5. **Database Migration Issue**
**File:** [lib/database/database_helper.dart](lib/database/database_helper.dart#L50)
- `onUpgrade` checks `if (oldVersion < 2)` but could create duplicate tables
- **Fix:** Add version checks to prevent duplicate creation
```dart
if (oldVersion < 4 && newVersion >= 4) {
  // Only create if not exists
}
```

### 6. **Context.mounted Check Missing**
**File:** [lib/screens/login_screen.dart](lib/screens/login_screen.dart#L177)
- Some async operations don't check `if (!context.mounted) return;` before using context
- **Fix:** Add checks in login/signup screens
```dart
bool ok = await db.login(emailController.text, passController.text);
if (!mounted) return;  // Add this
if (ok) { ... }
```

### 7. **No Error Handling for Database Operations**
**File:** [lib/screens/add_expense.dart](lib/screens/add_expense.dart#L368)
- `await db.addExpense(...)` has no try-catch
- **Fix:** Add error handling
```dart
try {
  await db.addExpense(...);
  if (mounted) Navigator.pop(context, true);
} catch (e) {
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Error: ${e.toString()}"))
  );
}
```

### 8. **CSV Export Special Characters Issue**
**File:** [lib/screens/settings_screen.dart](lib/screens/settings_screen.dart#L67)
- CSV export doesn't handle titles with commas or quotes
- **Fix:** ListToCsvConverter already handles this, but verify encoding

### 9. **Theme Notifier Not Properly Disposed**
**File:** [lib/main.dart](lib/main.dart#L6)
- Global `ValueNotifier` objects are never disposed
- **Fix:** Create a proper state management or add lifecycle management

### 10. **Date Format Inconsistency**
**File:** [lib/screens/home_screen.dart](lib/screens/home_screen.dart#L200)
- Stores dates as ISO8601 but display format might differ across locales
- **Fix:** Use consistent date formatting utility

---

## 🔮 FUTURE IMPROVEMENTS

### High Priority
1. **Password Hashing** - Use bcrypt or argon2
2. **Recurring Expense Automation** - Mark is_recurring but no automation exists
3. **Budget Alerts** - Settings exist but no notifications sent
4. **Input Validation** - Validate all user inputs (email format, amount range, etc.)
5. **Error Handling** - Add try-catch blocks throughout app

### Medium Priority
6. **Advanced Filtering**
   - Filter by date range
   - Filter by amount range
   - Search within categories

7. **Data Export Options**
   - JSON export (for backup)
   - PDF reports with charts
   - Excel support

8. **Multi-User Support**
   - Store user_id in expenses table
   - Support multiple accounts

9. **Edit/Delete Functionality**
   - Add updateExpense() method
   - Soft delete with restoration option

10. **Recurring Expenses Automation**
    - Auto-add recurring expenses on scheduled dates
    - Manual sync button

### Low Priority (Nice to Have)
11. **Cloud Backup & Sync**
    - Firebase integration
    - Automatic daily backup
    - Cross-device sync

12. **Advanced Analytics**
    - Month-to-month comparison
    - Spending trends (ML predictions)
    - Custom date range reports

13. **Widget Support**
    - Android widget for quick expense entry
    - Budget status widget

14. **Shared Expenses**
    - Split bills with friends
    - Shared budget tracking

15. **Tags/Labels**
    - Custom tags for expenses
    - Tag-based filtering and analytics

16. **Offline Mode**
    - Complete offline functionality
    - Sync when online

17. **Real-time Currency Conversion**
    - Fetch live exchange rates
    - Show currency pairs

18. **Receipt Image Attachment**
    - Camera capture
    - Gallery upload
    - OCR for amount extraction

---

## 📊 Code Quality Issues

1. **Magic Strings** - Category names repeated in multiple places
2. **No Constants** - Use enums for transaction types
3. **Duplicate Code** - Similar UI patterns in multiple screens
4. **No Logging** - Add proper logging for debugging
5. **Missing Tests** - No unit tests for business logic

---

## 🎯 Quick Fixes (Top 3)

1. **Fix Password Security**
2. **Add Email Uniqueness**
3. **Add Amount Validation & Error Handling**

