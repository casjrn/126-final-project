import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:upesov/features/pages/add_expense.dart';
import 'package:flutter/widget_previews.dart';

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
  // 1. State data for your Spending Chart
  List<ExpenseItem> _spendingItems = [
    ExpenseItem(category: 'Food', amount: 500, color: Colors.deepPurple),
    ExpenseItem(category: 'Transport', amount: 250, color: Colors.lightGreenAccent),
    ExpenseItem(category: 'School', amount: 150, color: Colors.pinkAccent),
    ExpenseItem(category: 'Others', amount: 50, color: Colors.white),
  ];

  // 2. State data for global savings tracking
  double _amountSaved = 5000;
  final double _targetAmount = 10000;

  // 3. State data for user wallets
  final Map<String, double> _walletBalances = {
    'Cash': 2500.0,
    'GCash': 1500.0,
    'Bank Account': 1000.0,
  };

  // Handles the primary "Add Expense" button action
  void _openAddExpenseDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddExpenseBox(),
    );
    
    if (result != null && result.containsKey('category') && result.containsKey('amount')) {
      final String category = result['category'];
      final double amount = double.tryParse(result['amount'].toString()) ?? 0.0;

      setState(() {
        final existingIndex = _spendingItems.indexWhere(
          (item) => item.category.toLowerCase() == category.toLowerCase()
        );
        
        if (existingIndex != -1) {
          _spendingItems[existingIndex].amount += amount;
        } else {
          _spendingItems.add(
            ExpenseItem(category: category, amount: amount, color: Colors.amber),
          );
        }
        
        // Deduct from a default source (e.g., Cash) and update global savings
        _walletBalances['Cash'] = (_walletBalances['Cash'] ?? 0.0) - amount;
        _amountSaved -= amount;
      });
    }
  }

  // Opens the pop-up confirmation menu when a Quick Select option button is tapped
  void _openQuickSelectPopup(BuildContext context, String itemTitle, double cost, String itemCategory) async {
    String selectedWallet = _walletBalances.keys.first;

    final bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Confirm Quick Purchase',
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
                        // Right Section: Interactive Dropdown layout selector
                        DropdownButton<String>(
                          value: selectedWallet,
                          dropdownColor: AppColors.cardBg,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.secondaryText),
                          style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                          underline: Container(height: 1, color: AppColors.borderColor),
                          items: _walletBalances.keys.map((String walletName) {
                            return DropdownMenuItem<String>(
                              value: walletName,
                              child: Text('$walletName (₱${_walletBalances[walletName]!.toStringAsFixed(0)})'),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedWallet = newValue;
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
                    // [Cancel Button]
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                    // [Save Button]
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      setState(() {
        if (_walletBalances.containsKey(selectedWallet)) {
          _walletBalances[selectedWallet] = _walletBalances[selectedWallet]! - cost;
          _amountSaved -= cost;
        }

        final existingIndex = _spendingItems.indexWhere(
          (item) => item.category.toLowerCase() == itemCategory.toLowerCase()
        );

        if (existingIndex != -1) {
          _spendingItems[existingIndex].amount += cost;
        } else {
          _spendingItems.add(
            ExpenseItem(category: itemCategory, amount: cost, color: Colors.amber),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        _buildDateHeader('Overview Tracker'), 
                        const SizedBox(height: 24),
                        _buildTotalSummaryCard(),
                        const SizedBox(height: 24),
                        _buildAnalyticsSection(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // ===== RIGHT AREA: QUICK SIDEBAR SELECTION (25% Width) =====
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
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

  // Pure isolated widget structure resolving the date alignment issue layout error
  Widget _buildDateHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title, 
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor), 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 24, color: AppColors.primaryText),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMMM dd, yyyy').format(DateTime.now()), 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(DateTime.now()), 
                    style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSummaryCard() {
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
                      // Renders dynamic segment items on the Pie chart
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 0,
                            sections: _spendingItems.map((item) {
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
                        children: _spendingItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              '${item.category}: ₱${item.amount.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColors.primaryText),
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
                    'Savings Summary',
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
                              PieChartSectionData(
                                value: _amountSaved < 0 ? 0 : _amountSaved,
                                color: Colors.deepPurple,
                                radius: 55,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: (_targetAmount - _amountSaved) < 0 ? 0 : (_targetAmount - _amountSaved),
                                color: Colors.white.withOpacity(0.2),
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
                            'Amount Saved:',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 4),
                          Text('₱${NumberFormat('#,###').format(_amountSaved)}', style: const TextStyle(color: AppColors.primaryText)),
                          const SizedBox(height: 20),
                          const Text(
                            'Target Amount:',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 4),
                          Text('₱${NumberFormat('#,###').format(_targetAmount)}', style: const TextStyle(color: AppColors.primaryText)),
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

  Widget _buildAnalyticsSection() {
    return Container(
      width: double.infinity,
      height: 380, 
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          SizedBox(height: 8),
          Text(
            'Visual breakdown of weekly spending trends',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          Expanded(
            child: Center(
              child: Icon(
                Icons.insert_chart_outlined,
                size: 80,
                color: AppColors.secondaryText,
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
            'Common UPV purchases',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 20),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildQuickSelectItem('Trike Fare', 15.00, 'Transport', Icons.directions_bike),
              _buildQuickSelectItem('Vnyrd Combo Meal', 69.00, 'Food', Icons.fastfood),
              _buildQuickSelectItem('Jeepney 5o City', 55.00, 'Transport', Icons.directions_bus),
              _buildQuickSelectItem('Photocopy', 5.00, 'School', Icons.print),
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
