# 💸 Expense Tracker App

> *"Manage your money, master your life"*

A fully-featured, cross-platform personal finance app built with **Flutter** and **SQLite**. Track your income and expenses, set category budgets, view analytics charts, export reports, and secure your data with biometric authentication.

---

## 📱 Screenshots

| Splash | Login | Home | Stats |
|--------|-------|------|-------|
| ![Onboard](images/onboard1.png) | ![Login](images/login.png) | ![Home](images/income.png) | ![Expense](images/expense.png) |

---

## ✨ Features

### 💰 Transaction Management
- Add **income** and **expense** transactions with title, amount, category, date, and account
- **Quick Add** buttons on the home screen for fast entry without opening a full form
- **Edit** any transaction by tapping it — all fields pre-filled, saves as an update
- **Delete** transactions with a swipe gesture
- Transactions sorted by date (newest first)

### 📊 Analytics & Stats
- **Pie / bar charts** (powered by `fl_chart`) breaking down spending by category
- **Daily trend charts** showing income vs expense over the last 7 / 30 days
- Account balance summary across all accounts (Cash, Bank, etc.)

### 🗂️ Budget Management
- Set per-category monthly spending limits
- Real-time budget usage progress bars
- Budgets stored per month so you can review past periods

### ⚙️ Settings & Customisation
- **Dark / Light theme** toggle — persisted across sessions
- **Multi-currency support**: BDT (৳), USD ($), EUR (€), INR (₹)
- **CSV export** — share a full transaction report via any installed share target
- **Biometric lock** (fingerprint / face) using `local_auth`
- Notification preference toggle
- Full database reset option

### 🔐 Authentication
- Local email + password sign-up / login
- Optional biometric login once enrolled

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) — SDK ^3.11.0 |
| Local Database | SQLite via `sqflite ^2.3.0` |
| Charts | `fl_chart ^0.66.0` |
| Biometrics | `local_auth ^2.2.0` |
| CSV Export | `csv ^6.0.0` + `share_plus ^10.1.2` |
| Date Formatting | `intl ^0.19.0` |
| File Paths | `path ^1.8.3` + `path_provider ^2.1.2` |
| Design System | Material 3 (`useMaterial3: true`) |

---

## 🗃️ Database Schema

```
users        → id, email, password
expenses     → id, title, amount, type, category, date, account, is_recurring
budgets      → id, category, limit_amount, month
settings     → key, value
```

The database uses **versioned migrations** (currently v4) to handle schema upgrades safely on existing installs.

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point, theme & currency notifiers
├── database/
│   └── database_helper.dart   # All SQLite CRUD, stats queries, settings
├── screens/
│   ├── splash_screen.dart     # Onboarding / launch screen
│   ├── login_screen.dart      # Login & navigation to signup
│   ├── signup_screen.dart     # New account creation
│   ├── home_screen.dart       # Dashboard: balance card, transaction list, quick-add
│   ├── add_expense.dart       # Add / Edit transaction form
│   ├── stats_screen.dart      # Charts and analytics
│   ├── budget_screen.dart     # Monthly category budgets
│   └── settings_screen.dart   # App preferences, export, biometrics
└── utils/
    └── app_theme.dart         # Centralised colors, shadows, text styles
images/
├── onboard.png / onboard1.png
├── login.png / signup.png
├── income.png / expense.png
└── boy1.jpg / like.png
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.11.0
- Dart SDK ≥ 3.0
- Android Studio / Xcode (for device/emulator)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/rahmatul-islam/Expense-trucker-app-new-costomize..git
cd Expense-trucker-app-new-costomize.

# 2. Install dependencies
flutter pub get

# 3. Run on your connected device or emulator
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web

# Windows / macOS / Linux desktop
flutter build windows   # or macos / linux
```

---

## 🧪 Testing

```bash
flutter test
```

A widget smoke test lives in `test/widget_test.dart`. Unit tests for database logic are a planned future addition.

---

## 🌐 Platform Support

| Platform | Status |
|---|---|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Web | ✅ Supported |
| Windows | ✅ Supported |
| macOS | ✅ Supported |
| Linux | ✅ Supported |

---

## ⚠️ Known Issues & Planned Fixes

| # | Issue | Priority |
|---|---|---|
| 1 | Passwords stored in plain text — needs SHA-256 / bcrypt hashing | 🔴 Critical |
| 2 | No UNIQUE constraint on user emails — duplicate accounts possible | 🔴 Critical |
| 3 | No input validation for negative or zero amounts | 🟠 High |
| 4 | `context.mounted` checks missing in some async callbacks | 🟠 High |
| 5 | No try-catch around all database operations | 🟠 High |
| 6 | Recurring expense flag stored but not auto-triggered | 🟡 Medium |
| 7 | Global `ValueNotifier` objects never disposed | 🟡 Medium |
| 8 | Date format may differ across locales | 🟡 Medium |

See [`BUG_AND_FUTURE_ANALYSIS.md`](BUG_AND_FUTURE_ANALYSIS.md) for full details and suggested code fixes.

---

## 🔮 Roadmap

**High Priority**
- [ ] Password hashing (bcrypt / argon2)
- [ ] Budget push notifications when limits are approached
- [ ] Advanced date-range and category filtering
- [ ] JSON / PDF export options

**Medium Priority**
- [ ] Cloud backup & cross-device sync (Firebase)
- [ ] Multi-user support (per-user expense isolation)
- [ ] Recurring expense automation (auto-insert on schedule)
- [ ] Month-over-month comparison charts

**Nice to Have**
- [ ] Receipt image attachment with OCR
- [ ] Home-screen widgets (Android / iOS)
- [ ] Live currency exchange rates
- [ ] Shared / split expenses between users
- [ ] ML-powered spending trend predictions

See [`THEME_AND_FEATURES_UPDATE.md`](THEME_AND_FEATURES_UPDATE.md) for a full changelog of recent UI and feature improvements.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repo
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

This project is private and not published to pub.dev. All rights reserved by the author.

---

## 👤 Author

**Rahmatul Islam**  
GitHub: [@rahmatul-islam](https://github.com/rahmatul-islam)

---

*Built with ❤️ using Flutter*
