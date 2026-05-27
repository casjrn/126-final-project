import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:upesov/features/pages/add_expense.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  final TextEditingController _monthInput = TextEditingController();
  final TextEditingController _dayInput = TextEditingController();
  final TextEditingController _yearInput = TextEditingController();

  String selectedCategory = 'All Categories';
  String selectedWallet = 'All Wallets';
  String selectedSort = 'All Expenses';
  String selectedTimeFilter = 'All'; 
  String selectedWeekOfMonth = 'All Weeks';

  int? filterYear;
  int? filterMonth;
  int? filterDay;

  String appliedCategory = 'All Categories';
  String appliedWallet = 'All Wallets';
  String appliedSort = 'All Expenses';
  String appliedWeekOfMonth = 'All Weeks';
  double? appliedMin;
  double? appliedMax;

  List<Map<String, dynamic>> expenses = [];

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _monthInput.dispose();
    _dayInput.dispose();
    _yearInput.dispose();
    super.dispose();
  }

  // expense summary chart implmentation that can be modified by the date filters
  List<Map<String, dynamic>> get summaryFilteredExpenses {
    if (expenses.isEmpty) return [];
    DateTime now = DateTime.now();
    
    return expenses.where((tx) {
      final txDate = tx['date'] as DateTime?;
      if (txDate == null) return false;

      bool matchesTime = true; 

      if (selectedTimeFilter == 'Today') {
        matchesTime = _isSameDay(txDate, now);
      } else if (selectedTimeFilter == 'This Week') {
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        matchesTime = txDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      } else if (selectedTimeFilter == 'This Month') {
        matchesTime = txDate.month == now.month && txDate.year == now.year;
      } else if (selectedTimeFilter == 'Custom') {
        if (filterYear != null) matchesTime &= (txDate.year == filterYear);
        if (filterMonth != null) matchesTime &= (txDate.month == filterMonth); 
        if (filterDay != null) matchesTime &= (txDate.day == filterDay); 
      }

      bool matchesWeek = true;
      if (appliedWeekOfMonth != 'All Weeks') {
        int weekNum = int.parse(appliedWeekOfMonth.split(' ')[1]);
        matchesWeek = _getWeekOfMonth(txDate) == weekNum;
      }

      return matchesTime && matchesWeek;
    }).toList();
  }

  double get totalSummaryAmount {
    return summaryFilteredExpenses.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['amount'].toString()) ?? 0.0);
    });
  }

  Map<String, double> get summaryCategoryTotals {
    Map<String, double> totals = {};
    for (var tx in summaryFilteredExpenses) {
      String cat = tx['category'] ?? 'Uncategorized';
      double amt = double.tryParse(tx['amount'].toString()) ?? 0.0;
      totals[cat] = (totals[cat] ?? 0.0) + amt;
    }
    var sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  // filter expenses for the table
  List<Map<String, dynamic>> get filteredExpenses {
    if (expenses.isEmpty) return [];
    List<Map<String, dynamic>> list = List.from(expenses);

    if (_searchController.text.isNotEmpty) {
      list = list.where((tx) => (tx['item'] ?? '').toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    if (appliedCategory != 'All Categories') list = list.where((tx) => tx['category'] == appliedCategory).toList();
    if (appliedWallet != 'All Wallets') list = list.where((tx) => tx['wallet'] == appliedWallet).toList();
    if (appliedMin != null) list = list.where((tx) => double.parse((tx['amount'] ?? '0').toString()) >= appliedMin!).toList();
    if (appliedMax != null) list = list.where((tx) => double.parse((tx['amount'] ?? '0').toString()) <= appliedMax!).toList();

    DateTime now = DateTime.now();
    list = list.where((tx) {
      final txDate = tx['date'] as DateTime?;
      if (txDate == null) return false;
      if (selectedTimeFilter == 'Today') return _isSameDay(txDate, now);
      if (selectedTimeFilter == 'This Week') {
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return txDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      }
      if (selectedTimeFilter == 'This Month') return txDate.month == now.month && txDate.year == now.year;
      if (selectedTimeFilter == 'Custom') {
        bool match = true;
        if (filterYear != null) match &= (txDate.year == filterYear);
        if (filterMonth != null) match &= (txDate.month == filterMonth);
        if (filterDay != null) match &= (txDate.day == filterDay);
        return match;
      }
      return true;
    }).toList();

    if (appliedWeekOfMonth != 'All Weeks') {
      int weekNum = int.parse(appliedWeekOfMonth.split(' ')[1]);
      list = list.where((tx) => _getWeekOfMonth(tx['date'] as DateTime) == weekNum).toList();
    }

    if (appliedSort == 'Amount (Highest - Lowest)') {
      list.sort((a, b) => double.parse((b['amount'] ?? '0').toString()).compareTo(double.parse((a['amount'] ?? '0').toString())));
    } else if (appliedSort == 'Amount (Lowest - Highest)') {
      list.sort((a, b) => double.parse((a['amount'] ?? '0').toString()).compareTo(double.parse((b['amount'] ?? '0').toString())));
    } else {
      list.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    }
    return list;
  }

  bool _isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;

  int _getWeekOfMonth(DateTime date) {
    int day = date.day;
    if (day <= 7) return 1;
    if (day <= 14) return 2;
    if (day <= 21) return 3;
    if (day <= 28) return 4;
    return 5;
  }

  void _showCustomDateFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Custom Date", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter numbers only. Leave blank to skip.", style: TextStyle(fontSize: 15, color: AppColors.secondaryText)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildDialogInput("Month (1-12)", _monthInput, 12)),
                const SizedBox(width: 8),
                Expanded(child: _buildDialogInput("Day (1-31)", _dayInput, 31)),
                const SizedBox(width: 8),
                Expanded(child: _buildDialogInput("Year", _yearInput, 2099)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.redAccent))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                filterMonth = int.tryParse(_monthInput.text);
                filterDay = int.tryParse(_dayInput.text);
                filterYear = int.tryParse(_yearInput.text);
                selectedTimeFilter = 'Custom';
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navGreen, foregroundColor: Colors.white),
            child: const Text("Apply Filter"),
          ),
        ],
      ),
    );
  }

  // input box for the custom date
  Widget _buildDialogInput(String hint, TextEditingController ctrl, int max) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.primaryText), 
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _MaxValFormatter(max)],
      decoration: InputDecoration(
        hintText: hint, 
        hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.navGreen, width: 1.5)),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      appliedCategory = selectedCategory;
      appliedWallet = selectedWallet;
      appliedSort = selectedSort;
      appliedWeekOfMonth = selectedWeekOfMonth;
      appliedMin = double.tryParse(_minAmountController.text);
      appliedMax = double.tryParse(_maxAmountController.text);
    });
  }

  void _resetFilters() {
    setState(() {
      selectedCategory = 'All Categories';
      selectedWallet = 'All Wallets';
      selectedSort = 'All Expenses';
      selectedTimeFilter = 'All';
      selectedWeekOfMonth = 'All Weeks';
      filterYear = null; filterMonth = null; filterDay = null;
      _monthInput.clear(); _dayInput.clear(); _yearInput.clear();
      _searchController.clear(); _minAmountController.clear(); _maxAmountController.clear();
      appliedCategory = 'All Categories';
      appliedWallet = 'All Wallets';
      appliedSort = 'All Expenses';
      appliedWeekOfMonth = 'All Weeks';
      appliedMin = null; appliedMax = null;
    });
  }

  void _openAddExpenseDialog() async {
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (context) => const AddExpenseBox());
    if (result != null) setState(() => expenses.insert(0, result));
  }

  void _editExpense(int index) async {
    final itemToEdit = filteredExpenses[index];
    final originalIndex = expenses.indexOf(itemToEdit);
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (context) => AddExpenseBox(initialData: itemToEdit));
    if (result != null) setState(() => expenses[originalIndex] = result);
  }

  void _confirmDelete(int index) {
    final itemToDelete = filteredExpenses[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFDF5E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        content: const Text('Are you sure you want to remove this transaction?', style: TextStyle(color: AppColors.primaryText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText))),
          ElevatedButton(
            onPressed: () { setState(() => expenses.remove(itemToDelete)); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'Manage'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _buildMainContent()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildSidebar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildTopActionBar(),
          const SizedBox(height: 25),
          _buildTimePeriod(),
          const SizedBox(height: 25),
          Expanded(child: _buildExpensesTable()),
        ],
      ),
    );
  }

  Widget _buildTopActionBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            style: const TextStyle(color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: 'Search for item...',
              hintStyle: const TextStyle(color: AppColors.secondaryText),
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryText),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderColor)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _openAddExpenseDialog,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.navGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Expense'),
        ),
      ],
    );
  }

  Widget _buildTimePeriod() {
    final filters = ['All', 'Today', 'This Week', 'This Month', 'Custom'];
    return Row(
      children: filters.map((filter) {
        bool isSelected = selectedTimeFilter == filter;
        String label = filter;
        if (filter == 'Custom' && (filterMonth != null || filterDay != null)) {
          label = "${filterMonth ?? 'MM'}/${filterDay ?? 'DD'}";
        }
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (val) => filter == 'Custom' ? _showCustomDateFilter() : setState(() { selectedTimeFilter = filter; filterYear = null; filterMonth = null; filterDay = null; }),
            selectedColor: AppColors.navGreen,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.primaryText, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppColors.navGreen : AppColors.borderColor)),
          ),
        );
      }).toList(),
    );
  }

  // shows all expenses/transactions
  Widget _buildExpensesTable() {
    final displayList = filteredExpenses;
    return Table(
      columnWidths: const { 0: FlexColumnWidth(1), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1), 5: FixedColumnWidth(100) },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle, 
      children: [
        _buildTableHeader(),
        for (int i = 0; i < displayList.length; i++) 
          _buildDataRow(
            i, 
            DateFormat('MM/dd/yy').format(displayList[i]['date'] ?? DateTime.now()), 
            (displayList[i]['item'] ?? '').toString(),
            (displayList[i]['category'] ?? '').toString(),
            (displayList[i]['wallet'] ?? '').toString(),
            '₱${displayList[i]['amount'] ?? '0'}',
          ),
      ],
    );
  }

  TableRow _buildTableHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 14);
    return TableRow(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      children: const [
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Date', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Item', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Category', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Wallet', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Amount', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Center(child: Text('Actions', style: headerStyle))),
      ],
    );
  }

  TableRow _buildDataRow(int index, String date, String desc, String cat, String wall, String amt) {
    const rowStyle = TextStyle(color: AppColors.primaryText, fontSize: 13);
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Text(date, style: rowStyle)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Text(desc, style: rowStyle)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Text(cat, style: rowStyle)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Text(wall, style: rowStyle)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Text(amt, style: rowStyle.copyWith(fontWeight: FontWeight.bold))),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryText), onPressed: () => _editExpense(index), constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
            const SizedBox(width: 4),
            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => _confirmDelete(index), constraints: const BoxConstraints(), padding: const EdgeInsets.all(8)),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterHeader(),
              _buildLabel("Category"),
              _buildDropdown(value: selectedCategory, items: ['All Categories', 'Food & Dining', 'Transportation', 'Personal Use & Hygiene', 'School Supplies & Academic Fees', 'Recreation & Leisure', 'Utilities & Load'], onChanged: (val) => setState(() => selectedCategory = val!)),
              _buildLabel("Wallets"),
              _buildDropdown(value: selectedWallet, items: ['All Wallets', 'Cash', 'GCash'], onChanged: (val) => setState(() => selectedWallet = val!)),
              _buildLabel("Week"),
              _buildDropdown(value: selectedWeekOfMonth, items: ['All Weeks', 'Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'], onChanged: (val) => setState(() => selectedWeekOfMonth = val!)),
              const SizedBox(height: 15),
              _buildAmountRangeRow(),
              _buildLabel("Sort by:"),
              _buildDropdown(value: selectedSort, items: ['All Expenses', 'Amount (Highest - Lowest)', 'Amount (Lowest - Highest)'], onChanged: (val) => setState(() => selectedSort = val!)),
              const SizedBox(height: 25),
              _buildApplyButton(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(child: _buildExpenseSummary()),
      ],
    );
  }

  Widget _buildExpenseSummary() {
    final total = totalSummaryAmount;
    final catMap = summaryCategoryTotals;
    final entries = catMap.entries.toList();
    
    List<Color> palette = [
      AppColors.navGreen, 
      AppColors.navOrange, 
      AppColors.buttonBlue, 
      Colors.deepPurpleAccent, 
      Colors.teal, 
      Colors.pinkAccent, 
      Colors.amber
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expense Summary', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 55,
                    sections: catMap.isEmpty 
                      ? [PieChartSectionData(color: Colors.grey.shade300, value: 1, radius: 25, showTitle: false)]
                      : entries.asMap().entries.map((entry) => PieChartSectionData(
                          color: palette[entry.key % palette.length],
                          value: entry.value.value,
                          radius: 25,
                          showTitle: false,
                        )).toList(),
                  ),
                ),
                _buildPieChartCenterText(total),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            appliedWeekOfMonth == 'All Weeks' 
              ? 'Categories (Filtered by Date)' 
              : 'Categories ($appliedWeekOfMonth)', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)
          ),
          const SizedBox(height: 10),
          ...entries.asMap().entries.map((entry) {
            double amt = entry.value.value;
            double percent = total > 0 ? (amt / total) * 100 : 0;
            return _buildCategoryRow(
              entry.value.key, 
              '₱${amt.toStringAsFixed(2)}', 
              '${percent.toStringAsFixed(1)}%', 
              palette[entry.key % palette.length]
            );
          }),
          if (catMap.isEmpty) 
            const Padding(
              padding: EdgeInsets.only(top: 10), 
              child: Text("No data for this selection", style: TextStyle(fontSize: 12, color: AppColors.secondaryText))
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true, dropdownColor: Colors.white, 
          icon: const Icon(Icons.expand_more, color: AppColors.primaryText), 
          style: const TextStyle(color: AppColors.primaryText, fontSize: 14), 
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryText)),
        ElevatedButton(onPressed: _resetFilters, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Reset', style: TextStyle(fontSize: 13))),
      ],
    );
  }

  Widget _buildAmountRangeRow() {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Min. Amount"), _buildSmallTextField('₱0.00', _minAmountController)])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Max. Amount"), _buildSmallTextField('₱0.00', _maxAmountController)])),
      ],
    );
  }

  Widget _buildSmallTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.primaryText, fontSize: 14), 
      decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderColor)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.navGreen, width: 1.5)))
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _applyFilters, style: ElevatedButton.styleFrom(backgroundColor: AppColors.navGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold))));
  }

  BoxDecoration _cardDecoration() => BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.borderColor));
  
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8, top: 8), child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText)));
  
  Widget _buildPieChartCenterText(double total) => Column(
    mainAxisSize: MainAxisSize.min, 
    children: [
      const Text('Total Expenses', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)), 
      Text('₱${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText))
    ]
  );
  
  Widget _buildCategoryRow(String name, String amount, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), 
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), 
        const SizedBox(width: 10), 
        Expanded(child: Text(name, style: const TextStyle(fontSize: 12, color: AppColors.primaryText))), 
        Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText)), 
        const SizedBox(width: 15), 
        Text(percent, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText))
      ]),
    );
  }
}

class _MaxValFormatter extends TextInputFormatter {
  final int maxVal;
  _MaxValFormatter(this.maxVal);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    if (newV.text.isEmpty) return newV;
    final val = int.tryParse(newV.text);
    return (val == null || val > maxVal) ? oldV : newV;
  }
}