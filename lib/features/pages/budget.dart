import 'package:flutter/material.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:upesov/providers/goal_provider.dart';
import 'package:upesov/providers/wallet_provider.dart';
import 'package:upesov/providers/expense_provider.dart'; 
import 'package:upesov/providers/budget_provider.dart'; 

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  bool _isBudgetSet = false;

  double get _currentPhysicalCash => context.watch<WalletProvider>().cashBalance;

  double get _spendableAmount {
    final target = context.watch<GoalProvider>().targetAmount;
    return _currentPhysicalCash - target;
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food & Dining', 'pct': 0.0},
    {'name': 'Transportation', 'pct': 0.0},
    {'name': 'Personal Use & Hygiene', 'pct': 0.0},
    {'name': 'School Supplies & Academic Fees', 'pct': 0.0},
    {'name': 'Recreation & Leisure', 'pct': 0.0},
    {'name': 'Utilities & Load', 'pct': 0.0},
  ];

  List<Map<String, dynamic>> get _enrichedCategories {
    final expenses = context.watch<ExpenseProvider>().expenses;

    return _categories.map((cat) {
      double totalActual = expenses.where((tx) {
        return (tx['categories']?['category_name'] ?? '') == cat['name'];
      }).fold(0.0, (sum, tx) {
        return sum + (double.tryParse(tx['expense_amount'].toString()) ?? 0.0);
      });

      return {
        ...cat,
        'act': totalActual,
      };
    }).toList();
  }

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().fetchGoal();
      context.read<WalletProvider>().fetchWallets();
      context.read<ExpenseProvider>().refresh();
    });
    for (var cat in _categories) {
      _controllers[cat['name']] = TextEditingController(text: (cat['pct'] ?? 0.0).toString());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderColor),
      );

  void _showSetTargetSavingsDialog() {
    final goalProv = context.read<GoalProvider>();
    TextEditingController targetController = TextEditingController(text: goalProv.targetAmount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Set Target Savings", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        content: TextField(
          controller: targetController,
          style: const TextStyle(color: AppColors.primaryText),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: "Target Amount", prefixText: "₱ "),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navGreen),
            onPressed: () async {
              double val = double.tryParse(targetController.text) ?? 0.0;
              await context.read<GoalProvider>().setTarget(val);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSavingsDialog() {
    final walletProv = context.read<WalletProvider>(); 
    final goalProv = context.read<GoalProvider>();     
    TextEditingController amountController = TextEditingController();
    Map<String, dynamic>? selectedWallet;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Add to Savings", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                style: const TextStyle(color: AppColors.primaryText),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Amount to Add", prefixText: "₱ "),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Map<String, dynamic>>(
                dropdownColor: Colors.white,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: const InputDecoration(
                  labelText: "Select Wallet",
                  labelStyle: TextStyle(color: AppColors.secondaryText),
                ),
                items: walletProv.wallets.map((w) => DropdownMenuItem<Map<String, dynamic>>(value: w, child: Text(w['wallet_name'] ?? 'Unnamed Wallet'))).toList(),
                onChanged: (val) => setDialogState(() => selectedWallet = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.redAccent))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.navGreen),
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount > 0 && selectedWallet != null) {
                  await goalProv.addSavings(amount);
                  await walletProv.addMoney(
                    selectedWallet!['wallet_id'].toString(),
                    (selectedWallet!['wallet_balance'] as num).toDouble(),
                    amount,
                  );  
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double totalPercentage = _categories.fold(0.0, (sum, item) => sum + (item['pct'] as double));
            bool isOverBudget = totalPercentage > 100.001;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Allocate Budget", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Distribute Percentages", style: TextStyle(fontSize: 15, color: AppColors.secondaryText, fontWeight: FontWeight.bold)),
                      if (isOverBudget) const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text("Total exceeds 100%!", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      ..._categories.map((cat) {
                        double expected = (_spendableAmount * ((cat['pct'] ?? 0.0) / 100));
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text(cat['name'], style: const TextStyle(color: Colors.black, fontSize: 13))),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: _controllers[cat['name']],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                                  decoration: const InputDecoration(suffixText: "%", contentPadding: EdgeInsets.zero),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (val) {
                                    setDialogState(() {
                                      cat['pct'] = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                              SizedBox(
                                width: 80,
                                child: Text("₱${expected.toStringAsFixed(2)}", textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navGreen, fontSize: 13)),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          Text("${totalPercentage.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, color: isOverBudget ? Colors.red : AppColors.navGreen)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navGreen),
                  onPressed: () {
                      if (!isOverBudget) {
                        final budgetProv = context.read<BudgetProvider>();
                        for (var cat in _categories) {
                          budgetProv.updateCategoryPct(cat['name'], cat['pct']);
                        }
                        budgetProv.setBudgetActive(true);
                        Navigator.pop(context);
                      }
                    },
                  child: const Text("Apply Budget", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<PieChartSectionData> _getSections(bool isExpected) {
  final List<Color> chartColors = [AppColors.buttonBlue, AppColors.navOrange, AppColors.navGreen, Colors.purple, Colors.amber, Colors.cyan];
  final categories = _enrichedCategories;

  double totalSpent = categories.fold(0, (sum, item) => sum + (item['act'] as double));

  return categories.asMap().entries.map((entry) {
    int index = entry.key;
    var cat = entry.value;
    
    double value = isExpected 
        ? (_spendableAmount * ((cat['pct'] ?? 0.0) / 100)) 
        : (cat['act'] ?? 0.0).toDouble();               

    double displayPct = 0;
    if (isExpected) {
      displayPct = (cat['pct'] ?? 0.0);
    } else {
      displayPct = totalSpent > 0 ? (value / totalSpent * 100) : 0;
    }

    return PieChartSectionData(
      color: chartColors[index % chartColors.length],
      value: value > 0 ? value : 0.001, 
      title: displayPct > 5 ? '${displayPct.toStringAsFixed(1)}%' : '',
      radius: 50,
      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    final budgetProv = context.watch<BudgetProvider>(); 
    final goalProv = context.watch<GoalProvider>();
    _isBudgetSet = budgetProv.isBudgetSet;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'BUDGET'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(children: [_buildHeaderActions(), const SizedBox(height: 24), _buildBudgetSection(), const SizedBox(height: 24), _buildAllocationCharts()]),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: Column(children: [
                const SizedBox(height: 65), 
                _buildSpendableAmountCard(goalProv.targetAmount), 
                const SizedBox(height: 24),
                _buildTotalSavedCard(goalProv.cumulativeAmount),
                const SizedBox(height: 24), 
                _buildSavingsGoalCard(goalProv.targetAmount, goalProv.currentAmount), 
                const SizedBox(height: 24), 
                _buildSavingsActions()
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSection() {
    final categories = _enrichedCategories;
    return Container(
      padding: const EdgeInsets.all(20), decoration: _cardDecoration(),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2.5), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1.2), 3: FlexColumnWidth(1.2), 4: FlexColumnWidth(1.2)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1)),
        children: [
          _buildTableRow(['Category', '% Allocated', 'Expected', 'Actual', 'Difference'], isHeader: true),
          ...categories.map((cat) {
            double expected = _spendableAmount * ((cat['pct'] ?? 0.0) / 100);
            double actual = (cat['act'] ?? 0.0).toDouble();
            double diff = expected - actual;
            String pctDisplay = _isBudgetSet ? "${(cat['pct'] ?? 0.0).toStringAsFixed(1)}%" : "-";
            String expDisplay = _isBudgetSet ? "₱${expected.toStringAsFixed(2)}" : "₱0.00";
            String actDisplay = _isBudgetSet ? "₱${actual.toStringAsFixed(2)}" : "₱0.00";
            String diffDisplay = _isBudgetSet ? "₱${diff.toStringAsFixed(2)}" : "₱0.00";
            return TableRow(children: [
              _tableCell(cat['name'], align: TextAlign.left), _tableCell(pctDisplay), _tableCell(expDisplay), _tableCell(actDisplay), _tableCell(diffDisplay, color: _isBudgetSet && diff < 0 ? Colors.red : AppColors.navGreen),
            ]);
          }),
        ],
      ),
    );
  }
  
  Widget _buildAllocationCharts() {
    return Container(
      padding: const EdgeInsets.all(24), decoration: _cardDecoration(),
      child: Column(children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text('EXPECTED ALLOCATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondaryText)),
          Text('ACTUAL ALLOCATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondaryText)),
        ]),
        const SizedBox(height: 30),
        SizedBox(height: 180, child: Row(children: [
          Expanded(child: PieChart(PieChartData(sections: _isBudgetSet ? _getSections(true) : [], centerSpaceRadius: 35, sectionsSpace: 2))),
          Expanded(child: PieChart(PieChartData(sections: _isBudgetSet ? _getSections(false) : [], centerSpaceRadius: 35, sectionsSpace: 2))),
        ])),
        const SizedBox(height: 30),
        _isBudgetSet ? _buildLegend() : const Text("Set a budget to view allocation charts", style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.secondaryText, fontSize: 12)),
      ]),
    );
  }

  Widget _buildLegend() {
    final List<Color> chartColors = [AppColors.buttonBlue, AppColors.navOrange, AppColors.navGreen, Colors.purple, Colors.amber, Colors.cyan];
    return Wrap(spacing: 16, runSpacing: 8, alignment: WrapAlignment.center, children: _categories.asMap().entries.map((entry) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: chartColors[entry.key % chartColors.length], shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(entry.value['name'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
      ]);
    }).toList());
  }

  Widget _buildSpendableAmountCard(double target) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weekly Budget', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 16)),
        const SizedBox(height: 12),
        Text('₱${_spendableAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _spendableAmount < 0 ? Colors.redAccent : AppColors.navGreen)),
        const SizedBox(height: 4),
        Text('Cash (₱${_currentPhysicalCash.toStringAsFixed(2)}) - Savings Goal (₱${target.toStringAsFixed(2)})', 
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),      ]),
    );
  }
  Widget _buildTotalSavedCard(double total) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Total Amount Saved', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 16)),
        const SizedBox(height: 12),
        Text('₱${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.buttonBlue)),
        const SizedBox(height: 4),
        const Text('Cumulative savings', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
      ]),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Budget Allocation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        ElevatedButton(
          onPressed: _showSetBudgetDialog,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navFocus, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Set Budget', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSavingsGoalCard(double target, double current) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weekly Savings Goal', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 20)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _savingsInfoColumn('Target:', '₱${target.toStringAsFixed(2)}'),
          _savingsInfoColumn('Amount Saved:', '₱${current.toStringAsFixed(2)}', isRight: true),
        ]),
        const SizedBox(height: 24),
        LinearProgressIndicator(value: target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0, minHeight: 8, backgroundColor: AppColors.borderColor, color: AppColors.navGreen),
        const SizedBox(height: 12),
        Center(child: Text('${target > 0 ? ((current / target) * 100).toInt() : 0}% reached', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText))),
      ]),
    );
  }

  Widget _savingsInfoColumn(String label, String value, {bool isRight = false}) {
    return Column(crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.navGreen)),
    ]);
  }

  Widget _buildSavingsActions() {
    return Row(children: [
      Expanded(child: _actionBtn('Set Target Savings', AppColors.buttonBlue, _showSetTargetSavingsDialog)),
      const SizedBox(width: 12),
      Expanded(child: _actionBtn('Add to Savings', AppColors.navGreen, _showAddSavingsDialog)),
    ]);
  }

  Widget _actionBtn(String title, Color color, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)));
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(children: cells.map((cell) => Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), child: Text(cell, textAlign: TextAlign.center, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, color: isHeader ? AppColors.primaryText : AppColors.secondaryText, fontSize: 13)))).toList());
  }

  Widget _tableCell(String text, {TextAlign align = TextAlign.center, Color? color}) {
    return Padding(padding: const EdgeInsets.all(12.0), child: Text(text, textAlign: align, style: TextStyle(fontSize: 13, color: color ?? AppColors.secondaryText)));
  }
}