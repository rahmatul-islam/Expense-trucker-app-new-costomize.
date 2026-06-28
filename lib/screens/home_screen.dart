import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../main.dart';
import 'add_expense.dart';
import 'login_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'budget_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> expenses = [];
  String searchQuery = "";
  String filterType = "All";
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final data = await db.getExpenses();
    setState(() {
      expenses = data;
    });
  }

  Map<String, int> getStats() {
    int total = 0;
    int income = 0;
    int expense = 0;
    for (var e in expenses) {
      int amt = (e['amount'] as num).toInt();
      if (e['type'] == "Expense") {
        expense += amt;
        total -= amt;
      } else {
        income += amt;
        total += amt;
      }
    }
    return {'total': total, 'income': income, 'expense': expense};
  }

  @override
  Widget build(BuildContext context) {
    final stats = getStats();

    return ValueListenableBuilder<String>(
      valueListenable: currencyNotifier,
      builder: (context, currency, child) {
        return Scaffold(
          extendBody: true,
          drawer: _buildDrawer(),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/onboard1.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A2940).withValues(alpha: 0.95),
                    const Color(0xFF16213E).withValues(alpha: 0.85),
                    const Color(0xFF0D1B2A).withValues(alpha: 0.92),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildAppBar(),
                    const SizedBox(height: 15),
                    _buildBalanceCard(stats, currency),
                    const SizedBox(height: 15),
                    _buildSearchFilterBar(),
                    const SizedBox(height: 15),
                    _buildTransactionHeader(),
                    _buildTransactionList(currency),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF6C63FF),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpense()),
              ).then((val) {
                if (val == true) loadData();
              });
            },
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.menu_rounded, color: Colors.white),
              ),
            ),
          ),
          const Column(
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "RATUL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              ).then((_) => loadData());
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.bar_chart_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, int> stats, String currency) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8E7CFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Current Balance",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "$currency ${stats['total']}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(
                      Icons.arrow_downward_rounded,
                      "Income",
                      "$currency${stats['income']}",
                      Colors.greenAccent,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _statItem(
                      Icons.arrow_upward_rounded,
                      "Expense",
                      "$currency${stats['expense']}",
                      Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quick Add Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _quickAddExpense(currency),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.redAccent, Colors.red.shade400],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Quick Expense",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _quickAddIncome(currency),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.trending_down_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Quick Income",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _quickAddExpense(String currency) async {
    _showQuickAddDialog("Add Expense", "Expense", currency);
  }

  Future<void> _quickAddIncome(String currency) async {
    _showQuickAddDialog("Add Income", "Income", currency);
  }

  void _showQuickAddDialog(String title, String type, String currency) {
    final amountCtrl = TextEditingController();
    final titleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Amount",
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixText: "$currency ",
                  prefixStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final amount = int.tryParse(amountCtrl.text);
                        if (amount != null &&
                            amount > 0 &&
                            titleCtrl.text.isNotEmpty) {
                          await db.addExpense(
                            titleCtrl.text,
                            amount,
                            type,
                            "Other",
                            DateTime.now().toIso8601String(),
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            loadData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$type added successfully!"),
                                backgroundColor: const Color(0xFF6C63FF),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim().toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search transactions...",
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Colors.white54,
                          size: 18,
                        ),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: ["All", "Expense", "Income"].map((type) {
              bool isSelected = filterType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        filterType = type;
                      });
                    }
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  selectedColor: const Color(0xFF6C63FF),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Month: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String currency) {
    final filteredExpenses = expenses.where((item) {
      final title = (item['title'] ?? "").toString().toLowerCase();
      final type = item['type'] ?? "";
      final matchesSearch = title.contains(searchQuery);
      final matchesFilter = filterType == "All" || type == filterType;
      return matchesSearch && matchesFilter;
    }).toList();

    return Expanded(
      child: filteredExpenses.isEmpty
          ? const Center(
              child: Text(
                "No transactions found",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final item = filteredExpenses[index];
                final isExpense = item['type'] == "Expense";
                final date =
                    DateTime.tryParse(item['date'] ?? "") ?? DateTime.now();

                return Dismissible(
                  key: Key(item['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (dir) async {
                    await db.deleteExpense(item['id']);
                    loadData();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddExpense(expenseData: item),
                                ),
                              ).then((val) {
                                if (val == true) loadData();
                              });
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (isExpense
                                            ? Colors.redAccent
                                            : Colors.greenAccent)
                                        .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                _getCategoryIcon(item['category']),
                                color: isExpense
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                              ),
                            ),
                            title: Text(
                              item['title'] ?? "No Title",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "${item['category'] ?? "Other"} • ${DateFormat('MMM dd').format(date)}",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              "${isExpense ? '-' : '+'} $currency ${(item['amount'] as num).toInt()}",
                              style: TextStyle(
                                color: isExpense
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: const Color(0xFF1E1E1E),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_filled, color: Color(0xFF6C63FF)),
              onPressed: loadData,
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.white54),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ).then((_) => loadData());
              },
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(
                Icons.donut_large_rounded,
                color: Colors.white54,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                ).then((_) => loadData());
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white54),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ).then((_) => loadData());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
              ),
            ),
            accountName: Text(
              "Rahmatul Islam Ratul",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text("Rahmatul@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
          ),
          _drawerTile(
            Icons.home_rounded,
            "Dashboard",
            () => Navigator.pop(context),
          ),
          _drawerTile(Icons.bar_chart_rounded, "Statistics", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ).then((_) => loadData());
          }),
          _drawerTile(Icons.donut_large_rounded, "Budgets", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetScreen()),
            ).then((_) => loadData());
          }),
          _drawerTile(Icons.settings_outlined, "Settings", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => loadData());
          }),
          const Spacer(),
          const Divider(color: Colors.white10),
          _drawerTile(Icons.logout_rounded, "Logout", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }, color: Colors.redAccent),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case "Food":
        return Icons.restaurant_rounded;
      case "Transport":
        return Icons.directions_bus_rounded;
      case "Shopping":
        return Icons.shopping_bag_rounded;
      case "Bills":
        return Icons.receipt_long_rounded;
      case "Health":
        return Icons.medical_services_rounded;
      case "Salary":
        return Icons.payments_rounded;
      case "Business":
        return Icons.business_center_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _drawerTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
