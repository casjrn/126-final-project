import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:upesov/theme/upesov_theme.dart';

class AddExpenseBox extends StatefulWidget {
  final Map<String, dynamic>? initialData; 
  final List<Map<String, String>> walletOptions;  
  final List<Map<String, String>> categoryOptions;

  const AddExpenseBox({
    super.key, 
    this.initialData, 
    required this.walletOptions, 
    required this.categoryOptions
  });

  @override
  State<AddExpenseBox> createState() => _AddExpenseBoxState();
}

class _AddExpenseBoxState extends State<AddExpenseBox> {
  late DateTime selectedDate;
  String? selectedCategoryId;
  String? selectedWalletId;
  bool _showErrors = false;

  late TextEditingController _amountController;
  late TextEditingController _itemController;



  @override
  void initState() {
    super.initState();
   
    selectedDate = widget.initialData?['expense_date'] != null
      ? DateTime.parse(widget.initialData!['expense_date'])
      : DateTime.now();
    selectedCategoryId = widget.initialData?['category_id'];
    selectedWalletId = widget.initialData?['wallet_id'];
    
    _amountController = TextEditingController(text: widget.initialData?['expense_amount']?.toString() ?? '');
    _itemController = TextEditingController(text: widget.initialData?['expense_description'] ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }
  
  void _handleSave() {
  setState(() => _showErrors = true);
    final String amount = _amountController.text.trim();
    if (amount.isEmpty || selectedCategoryId == null || selectedWalletId == null)  return;
    Navigator.pop(context, {
      'expense_date': selectedDate.toIso8601String(), 
      'expense_description': _itemController.text.isEmpty ? 'No item description' : _itemController.text,
      'category_id': selectedCategoryId, 
      'wallet_id': selectedWalletId,     
      'expense_amount': double.tryParse(amount) ?? 0.0, 
    });
}

  @override
  Widget build(BuildContext context) {
    final String dialogTitle = widget.initialData == null ? 'Add Expense' : 'Edit Expense';

    return Dialog(
      backgroundColor: const Color(0xFFFDF5E6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 850, 
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(dialogTitle),
            const SizedBox(height: 12),
            const Text('MAIN ENTRY FORM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondaryText)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildEntryForm()),
                const SizedBox(width: 40),
                Expanded(flex: 2, child: _buildSidebarSection()),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 24, color: AppColors.primaryText),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('MMMM dd, yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  Text(DateFormat('hh:mm a').format(DateTime.now()), style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSidebarSection() {
    bool isMissingFields = _showErrors && (_amountController.text.isEmpty || selectedCategoryId == null || selectedWalletId == null);
    return Column(
      children: [
        if (isMissingFields) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3))
            ),
            child: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please fill in all required (*) fields to save.', 
                    style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)
                  )
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint, TextEditingController controller, bool hasError) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label, icon),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.primaryText),
            decoration: _inputDecoration(hint, hasError),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required String? selectedValue, 
    required bool hasError,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label, icon),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: items.contains(selectedValue) ? selectedValue : null,
            isExpanded: true,
            isDense: true, 
            menuMaxHeight: 300, 
            hint: Text(hint, style: const TextStyle(color: AppColors.secondaryText, fontSize: 13)),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
            icon: const Icon(Icons.expand_more, color: AppColors.primaryText),
            
            decoration: _inputDecoration('', hasError).copyWith(
              fillColor: Colors.white, 
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: items.toSet().map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool hasError) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: hasError ? Colors.red : AppColors.borderColor, width: hasError ? 2 : 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: hasError ? Colors.red : AppColors.navGreen, width: 2),
      ),
    );
  }

  Widget _buildEntryForm() {
    return Column(
      children: [
        Row(
          children: [
            _buildTextField('Amount (PHP) *', Icons.payments_outlined, '0.00', _amountController, _showErrors && _amountController.text.isEmpty),
            const SizedBox(width: 16),
            _buildDropdownField(
              label: 'Category *',
              icon: Icons.label_outline,
              hint: 'Select a category...',
              items: widget.categoryOptions.map((e) => e['name']!).toList(),
              selectedValue: widget.categoryOptions.any((e) => e['id'] == selectedCategoryId)
                  ? widget.categoryOptions.firstWhere((e) => e['id'] == selectedCategoryId)['name']
                  : null,
              onChanged: (val) {
                setState(() {
                  final selected = widget.categoryOptions.firstWhere((e) => e['name'] == val);
                  selectedCategoryId = selected['id'];
                });
              },
              hasError: _showErrors && selectedCategoryId == null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildDatePickerField('Date *', Icons.calendar_month_outlined),
            const SizedBox(width: 16),
            _buildDropdownField(
              label: 'Wallet *',
              icon: Icons.account_balance_wallet_outlined,
              hint: 'Select a wallet...',
              items: widget.walletOptions.map((e) => e['name']!).toList(),
              selectedValue: widget.walletOptions.any((e) => e['id'] == selectedWalletId)
                  ? widget.walletOptions.firstWhere((e) => e['id'] == selectedWalletId)['name']
                  : null,
              onChanged: (val) {
                setState(() {
                  final selected = widget.walletOptions.firstWhere((e) => e['name'] == val);
                  selectedWalletId = selected['id'];
                });
              },
              hasError: _showErrors && selectedWalletId == null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _builditemField(_itemController),
      ],
    );
  }

  Widget _buildDatePickerField(String label, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label, icon),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: _inputDecoration('', false),
              child: Text(DateFormat('MM/dd/yyyy').format(selectedDate), style: const TextStyle(color: AppColors.primaryText)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _builditemField(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Item (eg: Coffee)', Icons.notes),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: _inputDecoration('Add item name/description...', false),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryText),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
      ],
    );
  }

  /*Widget _buildBudgetFeedback() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), border: Border.all(color: AppColors.borderColor), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Budget Feedback', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 100, width: 100,
                child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 30, sections: [
                  PieChartSectionData(color: AppColors.navOrange, value: 70, radius: 15, showTitle: false),
                  PieChartSectionData(color: AppColors.buttonBlue, value: 30, radius: 15, showTitle: false),
                ])),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedCategory?.toUpperCase() ?? 'CATEGORY', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
                    const Text('Budget: ₱0.00', style: TextStyle(fontSize: 11, color: AppColors.primaryText)),
                    const SizedBox(height: 4),
                    const Text('After this expense:', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                    const Text('0%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }*/

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave, 
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navGreen, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: const Text('Save Log'),
        ),
      ],
    );
  }
}