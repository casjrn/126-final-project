import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widget_previews.dart';

import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:upesov/features/pages/add_expense.dart';
import 'package:upesov/providers/expense_provider.dart';
import 'package:upesov/providers/wallet_provider.dart';
import 'package:upesov/providers/goal_provider.dart';

@Preview(name: 'Dashboard Layout Preview')
Widget previewDashboard() {
  return const DashboardPage();
}

// Data Model to manage dynamic spending categories
class ExpenseItem {
  final String category;
  double amount;
  final Color color;

  ExpenseItem({
    required this.category,
    required this.amount,
    required this.color,
  });
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Pre-defined palette for dynamic category chart colors
  final List<Color> _chartColors = [
    AppColors.darkGreen,
    Colors.lightGreenAccent,
    Colors.pinkAccent,
    Colors.amber,
    Colors.cyan,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    // Fetch initial data just in case they aren't loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().refresh();
      context.read<WalletProvider>().refresh();
      context.read<GoalProvider>().fetchGoal(); // Ensure goals are fetched too
    });
  }

  // Handles the primary "Add Expense" button action
  void _openAddExpenseDialog(BuildContext context) async {
    final expenseProv = context.read<ExpenseProvider>();
    final walletProv = context.read<WalletProvider>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddExpenseBox(
        walletOptions: expenseProv.walletOptions,
        categoryOptions: expenseProv.categoryOptions,
      ),
    );
    
    if (result != null) {
      // 1. Log the expense to Supabase
      await expenseProv.addExpense(result);

      // 2. Automatically deduct from the selected wallet
      final walletId = result['wallet_id'];
      final amount = result['expense_amount'];
      
      final wallet = walletProv.wallets.firstWhere(
        (w) => w['wallet_id'].toString() == walletId.toString(),
        orElse: () => {}
      );

      if (wallet.isNotEmpty) {
        final currentBalance = double.tryParse(wallet['wallet_balance'].toString()) ?? 0.0;
        await walletProv.deductMoney(walletId.toString(), currentBalance, amount);
      }
    }
  }

  // Opens the pop-up confirmation menu when a Quick Select option button is tapped
  void _openQuickSelectPopup(BuildContext context, String itemTitle, double cost, String itemCategoryName) async {
    final expenseProv = context.read<ExpenseProvider>();
    final walletProv = context.read<WalletProvider>();

    if (walletProv.wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a wallet first.', style: TextStyle(color: Colors.white))),
      );
      return;
    }

    // Default to the first available wallet
    String selectedWalletId = walletProv.wallets.first['wallet_id'].toString();

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Confirm Logging Expense',
                style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Section: Title & Price labels
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${cost.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.navGreen, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        // Right Section: Interactive Dropdown layout selector from real wallets
                        DropdownButton<String>(
                          value: selectedWalletId,
                          dropdownColor: AppColors.cardBg,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondaryText),
                          style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                          underline: Container(height: 1, color: AppColors.borderColor),
                          items: walletProv.wallets.map((wallet) {
                            final wId = wallet['wallet_id'].toString();
                            final wName = wallet['wallet_name'].toString();
                            final wBal = double.tryParse(wallet['wallet_balance'].toString()) ?? 0.0;
                            
                            return DropdownMenuItem<String>(
                              value: wId,
                              child: Text('$wName (₱${wBal.toStringAsFixed(0)})'),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedWalletId = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 20, bottom: 20, left: 20),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Log Fast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    // If the user chooses to complete the entry transaction
    if (shouldSave == true) {
      try {
        debugPrint("Attempting Quick Log: $itemTitle - $itemCategoryName");

        // Safely map the UI string to the Database Category
        final catOpt = expenseProv.categoryOptions.firstWhere(
          (c) {
            final dbCatName = (c['name'] ?? c['category_name'] ?? '').toString().toLowerCase().trim();
            return dbCatName == itemCategoryName.toLowerCase().trim();
          },
          orElse: () {
            debugPrint("Category '$itemCategoryName' not found in database!");
            return {};
          }
        );
        
        final String categoryId = (catOpt['id'] ?? catOpt['category_id'] ?? '').toString();
        
        if (categoryId.isNotEmpty) {
          // 1. Add to Expense table
          await expenseProv.addExpense({
            'expense_date': DateTime.now().toIso8601String(),
            'expense_description': itemTitle,
            'category_id': categoryId,
            'wallet_id': selectedWalletId,
            'expense_amount': cost,
          });

          // 2. Deduct from Wallet table
          final wallet = walletProv.wallets.firstWhere((w) => w['wallet_id'].toString() == selectedWalletId);
          final currentBalance = double.tryParse(wallet['wallet_balance'].toString()) ?? 0.0;
          await walletProv.deductMoney(selectedWalletId, currentBalance, cost);

          debugPrint("Quick Log Successful!");
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense logged successfully!', style: TextStyle(color: Colors.white))),
            );
          }
        } else {
          debugPrint("Failed to log: Category ID is empty.");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Category "$itemCategoryName" not found in database.', style: const TextStyle(color: Colors.white))),
            );
          }
        }
      } catch (e) {
        debugPrint("Quick Select Error: $e");
      }
    }
  }

  // Helper method to calculate dynamic spending lists
  List<ExpenseItem> _getDynamicSpendingItems(ExpenseProvider expenseProv) {
    Map<String, double> totals = {};
    
    for (var exp in expenseProv.expenses) {
      final category = exp['categories']?['category_name'] ?? 'Others';
      final amount = double.tryParse(exp['expense_amount']?.toString() ?? '0') ?? 0.0;
      totals[category] = (totals[category] ?? 0.0) + amount;
    }

    int colorIndex = 0;
    return totals.entries.map((entry) {
      final color = _chartColors[colorIndex % _chartColors.length];
      colorIndex++;
      return ExpenseItem(category: entry.key, amount: entry.value, color: color);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers to trigger automatic UI repaints
    final expenseProv = context.watch<ExpenseProvider>();
    final goalProv = context.watch<GoalProvider>();
    
    final spendingItems = _getDynamicSpendingItems(expenseProv);
    
    // Explicitly binding variables for Total Savings and Weekly Goal
    final totalSavings = goalProv.cumulativeAmount;; 
    final weeklyGoal = goalProv.targetAmount; 

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'DASHBOARD'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== LEFT AREA: MAIN TRACKING PANEL (75% Width) =====
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.borderColor, thickness: 1, height: 40),
                        
                        const Text(
                          'Overview Tracker', 
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                        ), 

                        const SizedBox(height: 24),
                        _buildTotalSummaryCard(spendingItems, totalSavings, weeklyGoal),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // ===== RIGHT AREA: QUICK SIDEBAR SELECTION (25% Width) =====
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDateTimeCard(), // Moved here above Quick Select
                        const SizedBox(height: 24),
                        _buildQuickSelectSidebar(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // New Date & Time Card Widget
  Widget _buildDateTimeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.borderColor), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 28, color: AppColors.primaryText),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM dd, yyyy').format(DateTime.now()), 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('hh:mm a').format(DateTime.now()), 
                style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(List<ExpenseItem> spendingItems, double totalSavings, double weeklyGoal) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          // ===== SPENDING PANEL COLLATERAL =====
          SizedBox(
            width: 500,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.infoContainer1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spending Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: spendingItems.isEmpty 
                            ? const Center(child: Text('No Data', style: TextStyle(color: AppColors.secondaryText)))
                            : PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                  sections: spendingItems.map((item) {
                                    return PieChartSectionData(
                                      value: item.amount,
                                      color: item.color,
                                      radius: 60,
                                      showTitle: false,
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      // Dynamic List Legend tracking
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: spendingItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.category}: ₱${item.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ===== SAVINGS CHART BLOCK =====
          SizedBox(
            width: 500,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.infoContainer1,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saving Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Donut tracking circle
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 20,
                            sections: [
                              // Donut fill logic based on totalSavings vs weeklyGoal
                              PieChartSectionData(
                                value: totalSavings < 0 ? 0 : totalSavings,
                                color: AppColors.darkGreen,
                                radius: 55,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: (weeklyGoal - totalSavings) < 0 ? 0 : (weeklyGoal - totalSavings),
                                color: Colors.white.withValues(alpha: 0.2),
                                radius: 55,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Text descriptions
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Savings:', 
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 4),
                          Text('₱${NumberFormat('#,###').format(totalSavings)}', style: const TextStyle(color: AppColors.primaryText)),
                          const SizedBox(height: 20),
                          const Text(
                            'Weekly Savings Goal:', 
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 4),
                          Text('₱${NumberFormat('#,###').format(weeklyGoal)}', style: const TextStyle(color: AppColors.primaryText)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectSidebar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'UPV Quick Select',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(height: 4),
          const Text(
            'Common UPV expenses',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 20),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildQuickSelectItem('Trike Fare', 15.00, 'Transportation', Icons.directions_bike),
              _buildQuickSelectItem('Vnyrd Combo Meal', 69.00, 'Food & Dining', Icons.fastfood),
              _buildQuickSelectItem('Jeepney to City', 55.00, 'Transportation', Icons.directions_bus),
              _buildQuickSelectItem('Photocopy', 5.00, 'School Supplies & Academic Fees', Icons.print),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectItem(String title, double cost, String category, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openQuickSelectPopup(context, title, cost, category),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.secondaryText, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₱${cost.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      crossAxisAlignment: CrossAxisAlignment.center,      
      children: [
        const Text(
          'Hello, User!',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,  
          ),
        ),  
        ElevatedButton.icon(
          onPressed: () => _openAddExpenseDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navGreen, 
            foregroundColor: Colors.white, 
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            'Add Expense',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}