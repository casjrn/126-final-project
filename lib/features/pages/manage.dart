import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  String selectedCategory = 'All Categories';
  String selectedWallet = 'All Wallets';
  String selectedSort = 'Current Date';
  String selectedTimeFilter = 'All';

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
          _buildTimePeriodChips(),
          const SizedBox(height: 25),
          Expanded(child: _buildTransactionTable()),
        ],
      ),
    );
  }

  Widget _buildTopActionBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: const TextStyle(color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: 'Search for date, category, or wallet...',
              hintStyle: const TextStyle(color: AppColors.secondaryText),
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryText),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryText,
            side: const BorderSide(color: AppColors.borderColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
          icon: const Icon(Icons.upload_file, size: 18),
          label: const Text('Export'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            // add expense pop-uppp
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Expense'),
        ),
      ],
    );
  }

  Widget _buildTimePeriodChips() {
    final filters = ['All', 'Today', 'This Week', 'This Month', 'Custom'];
    return Row(
      children: filters.map((filter) {
        bool isSelected = selectedTimeFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (val) => setState(() => selectedTimeFilter = filter),
            selectedColor: AppColors.navGreen,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isSelected ? AppColors.navGreen : AppColors.borderColor),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FixedColumnWidth(100), 
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle, 
      children: [
        _buildTableHeader(),
        _buildDataRow('05/24/26', 'Coffee', 'Food', 'Cash', '₱150.00'),
        _buildDataRow('05/23/26', 'Electric Bill', 'Bills', 'Bank', '₱2,400.00'),
      ],
    );
  }

  TableRow _buildTableHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 14);
    return TableRow(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      children: const [
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Date', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Description', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Category', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Wallet', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Text('Amount', style: headerStyle)),
        Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Center(child: Text('Actions', style: headerStyle))),
      ],
    );
  }

  TableRow _buildDataRow(String date, String desc, String cat, String wall, String amt) {
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
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryText),
              onPressed: () {}, 
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
              onPressed: () {}, 
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
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
              _buildDropdown(
                value: selectedCategory,
                items: ['All Categories', 'Food & Dining', 'Transportation', 'Personal Use & Hygiene', 'School Supplies & Academic Fees', 'Recreation & Leisure', 'Utilities & Load'],
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
              _buildLabel("Wallets"),
              _buildDropdown(
                value: selectedWallet,
                items: ['All Wallets', 'Cash', 'GCash'],
                onChanged: (val) => setState(() => selectedWallet = val!),
              ),
              const SizedBox(height: 15),
              _buildAmountRangeRow(),
              _buildLabel("Sort by:"),
              _buildDropdown(
                value: selectedSort,
                items: ['Current Date', 'Amount (Highest - Lowest)', 'Amount (Lowest - Highest)'],
                onChanged: (val) => setState(() => selectedSort = val!),
              ),
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

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.expand_more, color: AppColors.primaryText),
          style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Filters',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.primaryText,
        ),
      ),
      ElevatedButton(
        onPressed: () {
          // implement clear fields 
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent, 
          foregroundColor: Colors.white,    
          elevation: 0,                    
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reset',
          style: TextStyle(
            //fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildAmountRangeRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Min. Amount"),
              _buildSmallTextField('₱0.00'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Max. Amount"),
              _buildSmallTextField('₱0.00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTextField(String hint) {
  return TextField(
    style: const TextStyle(
      color: AppColors.primaryText, 
      fontSize: 14,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navGreen, width: 1.5),
      ),
    ),
  );
}

  Widget _buildExpenseSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expense Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 55,
                    sections: [
                      PieChartSectionData(color: AppColors.navGreen, value: 45, radius: 25, showTitle: false),
                      PieChartSectionData(color: AppColors.navOrange, value: 35, radius: 25, showTitle: false),
                      PieChartSectionData(color: AppColors.buttonBlue, value: 20, radius: 25, showTitle: false),
                    ],
                  ),
                ),
                _buildPieChartCenterText(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Top Categories', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          const SizedBox(height: 10),
          _buildCategoryRow('Food & Dining', '₱1000', '45%', AppColors.navGreen),
          _buildCategoryRow('Transportation', '₱150', '35%', AppColors.navOrange),
          _buildCategoryRow('Utilities & Load', '₱200', '20%', AppColors.buttonBlue),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // apply filter implementation
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: AppColors.borderColor),
  );

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 8),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
  );

  Widget _buildPieChartCenterText() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Total Expenses', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
        Text('₱1,350', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
      ],
    );
  }

  Widget _buildCategoryRow(String name, String amount, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12, color: AppColors.primaryText))),
          Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          const SizedBox(width: 15),
          Text(percent, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}