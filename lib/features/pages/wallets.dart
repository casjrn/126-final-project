import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:upesov/providers/wallet_provider.dart';

// ==========================================
// 1. LOGIC LAYER (CONTROLLER)
// ==========================================

class WalletsController {
  final State state;
  WalletsController(this.state);

  BuildContext get context => state.context;

  // Data State
  List<String> logs = []; // Removed 'final' so we can overwrite it when loading
  String? errorMessage;

  // Storage Key
  static const String _logsKey = 'wallet_activity_logs';

  void init() {
    _loadLogs(); // Load saved logs when the page initializes
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.mounted) {
        context.read<WalletProvider>().refresh();
      }
    });
  }

  // --- Local Storage Logic ---
  
  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogs = prefs.getStringList(_logsKey) ?? [];
    
    if (state.mounted) {
      // ignore: invalid_use_of_protected_member
      state.setState(() => logs = savedLogs);
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_logsKey, logs);
  }

  // --- Formatting Logic ---
  
  String formatCurrency(double v) {
    return v.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), 
      (m) => '${m[1]},'
    );
  }

  void clearError() {
    // ignore: invalid_use_of_protected_member
    state.setState(() => errorMessage = null);
  }

  void setError(String error) {
    // ignore: invalid_use_of_protected_member
    state.setState(() => errorMessage = error);
  }

  // --- Logic Actions ---
  
  Future<void> addWallet({required String name, required String type, required double balance}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await context.read<WalletProvider>().addWallet(
        userId: user.id,
        name: name,
        type: type,
        balance: balance,
      );
      _updateLogs('Added ₱${formatCurrency(balance)} to $name');
    }
  }

  Future<void> topUp({required Map<String, dynamic> wallet, required double amount}) async {
    await context.read<WalletProvider>().addMoney(
      wallet['wallet_id'].toString(),
      (wallet['wallet_balance'] ?? 0.0) as double,
      amount,
    );
    _updateLogs('Topped up ${wallet['wallet_name']} +₱${formatCurrency(amount)}');
  }

  Future<void> transfer({
    required Map<String, dynamic> from,
    required Map<String, dynamic> to,
    required double amount,
  }) async {
    await context.read<WalletProvider>().transferMoney(
      fromId: from['wallet_id'].toString(),
      toId: to['wallet_id'].toString(),
      amount: amount,
    );
    _updateLogs('Transferred ₱${formatCurrency(amount)}: ${from['wallet_name']} ➔ ${to['wallet_name']}');
  }

  void _updateLogs(String message) {
    // ignore: invalid_use_of_protected_member
    state.setState(() {
      logs.insert(0, message);
      
      // Optional: Cap the logs at 50 to prevent infinite memory growth over time
      if (logs.length > 50) {
        logs.removeLast();
      }
    });
    
    // Save to local storage whenever a new log is added
    _saveLogs(); 
  }
}

// ==========================================
// 2. UI LAYER (PAGE)
// ==========================================

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  late final WalletsController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = WalletsController(this);
    _controller.init();
  }

  // --- Main Build ---

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WalletProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'WALLETS'),
      body: wp.isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryText))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            // Fix: Removed IntrinsicHeight and changed CrossAxisAlignment
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildMainContent(wp.wallets, wp.totalBalance)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildSidebar()),
              ],
            ),
          ),
    );
  }

  // --- UI Components ---

  Widget _buildMainContent(List<Map<String, dynamic>> wallets, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Total Summary"),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Balance Across All Wallets',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                const SizedBox(height: 8),
                Text('₱${_controller.formatCurrency(total)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader("My Active Wallets"),
          const SizedBox(height: 16),

          wallets.isEmpty 
            ? const Text("No wallets registered yet.", style: TextStyle(color: AppColors.secondaryText))
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: wallets.map((w) => _buildWalletCard(w)).toList(),
              ),
          
          const SizedBox(height: 40),
          _buildSectionHeader("Wallet Management Tools"),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(Icons.account_balance_wallet, "Add Wallet", _showAddWalletDialog),
              _buildActionButton(Icons.add_card, "Top Up Wallet", _showTopUpDialog),
              _buildActionButton(Icons.swap_horiz, "Transfer Money", _showTransferDialog),
            ],
          ),

          if (_controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWalletCard(Map<String, dynamic> wallet) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(wallet['wallet_name'] ?? 'Wallet',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          const SizedBox(height: 4),
          Text(wallet['wallet_type'] ?? 'Cash',
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
          const SizedBox(height: 16),
          Text("₱${_controller.formatCurrency((wallet['wallet_balance'] ?? 0.0) as double)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Fix: Keeps column compact
        children: [
          _buildSectionHeader("Recent Activity Logs"),
          const SizedBox(height: 16),
          if (_controller.logs.isEmpty)
            const Text(
              'No activity logs found.', 
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText)
            )
          else
            ListView.separated(
              shrinkWrap: true, // Fix: Lets ListView have a specific height
              physics: const NeverScrollableScrollPhysics(), // Fix: Prevents scroll fighting
              itemCount: _controller.logs.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.borderColor),
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _controller.logs[i],
                  style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Logic-Triggered Dialogs ---

  void _dialogShell({
    required String title,
    required String action,
    required List<Widget> Function(StateSetter ss) fields,
    required Future<void> Function() onSave,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: fields(ss)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: AppColors.secondaryText)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryText, 
                foregroundColor: AppColors.cardBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                try {
                  await onSave();
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog() {
    final name = TextEditingController(), bal = TextEditingController();
    var type = 'Cash';
    _controller.clearError();
    
    _dialogShell(
      title: 'Add New Wallet',
      action: 'Save Wallet',
      onSave: () => _controller.addWallet(
        name: name.text.trim(),
        type: type,
        balance: double.tryParse(bal.text) ?? 0.0,
      ),
      fields: (ss) => [
        const SizedBox(height: 10),
        TextFormField(
          controller: name,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: _inputField('Wallet Name'),
          autofillHints: const[],
          validator: (v) => (v == null || v.isEmpty) ? "Name is required" : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: _inputField('Account Type'),
          style: const TextStyle(color: AppColors.primaryText, fontSize: 16),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryText),
          dropdownColor: AppColors.cardBg,
          items: ['Cash', 'Bank Account', 'E-Wallet']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => ss(() => type = v!),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: bal,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: _inputField('Initial Balance', currency: true),
          autofillHints: const[],
          validator: (v) => double.tryParse(v ?? '') == null ? "Enter a valid number" : null,
        ),
      ],
    );
  }

  void _showTopUpDialog() {
    final wallets = context.read<WalletProvider>().wallets;
    if (wallets.isEmpty) {
      _controller.setError("No wallets available. Add one first.");
      return;
    }
    _controller.clearError();
    final amt = TextEditingController();
    var selected = wallets.first;

    _dialogShell(
      title: 'Top Up Wallet',
      action: 'Top Up',
      onSave: () => _controller.topUp(wallet: selected, amount: double.parse(amt.text)),
      fields: (ss) => [
        const SizedBox(height: 10),
        DropdownButtonFormField<Map<String, dynamic>>(
          initialValue: selected,
          decoration: _inputField('Select Wallet'),
          style: const TextStyle(color: AppColors.primaryText, fontSize: 16),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryText),
          dropdownColor: AppColors.cardBg,
          items: wallets
              .map((w) => DropdownMenuItem(
                    value: w,
                    child: Text(w['wallet_name'] ?? 'Wallet'),
                  ))
              .toList(),
          onChanged: (v) => ss(() => selected = v!),
          validator: (v) => v == null ? "Select a wallet" : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: amt,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: _inputField('Amount to Add', currency: true),
          autofillHints: const[],
          validator: (v) {
            final p = double.tryParse(v ?? '');
            return (p == null || p <= 0) ? "Enter a valid amount" : null;
          },
        ),
      ],
    );
  }

  void _showTransferDialog() {
    final wallets = context.read<WalletProvider>().wallets;
    if (wallets.length < 2) {
      _controller.setError("Need at least 2 wallets to transfer.");
      return;
    }

    _controller.clearError();
    final amt = TextEditingController();
    var from = wallets[0], to = wallets[1];

    _dialogShell(
      title: 'Quick Transfer',
      action: 'Transfer',
      onSave: () => _controller.transfer(from: from, to: to, amount: double.parse(amt.text)),
      fields: (ss) => [
        const SizedBox(height: 10),
        DropdownButtonFormField<Map<String, dynamic>>(
          initialValue: from,
          decoration: _inputField('From Wallet'),
          style: const TextStyle(color: AppColors.primaryText, fontSize: 16),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryText),
          dropdownColor: AppColors.cardBg,
          items: wallets
              .map((w) => DropdownMenuItem(value: w, child: Text(w['wallet_name'] ?? 'Wallet')))
              .toList(),
          onChanged: (v) => ss(() {
            from = v!;
            if (to['wallet_id'] == from['wallet_id']) {
              to = wallets.firstWhere(
                (w) => w['wallet_id'] != from['wallet_id'],
                orElse: () => wallets[0],
              );
            }
          }),
          validator: (v) => v == null ? "Select source wallet" : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<Map<String, dynamic>>(
          initialValue: to,
          decoration: _inputField('To Wallet'),
          style: const TextStyle(color: AppColors.primaryText, fontSize: 16),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryText),
          dropdownColor: AppColors.cardBg,
          items: wallets
              .where((w) => w['wallet_id'] != from['wallet_id'])
              .map((w) => DropdownMenuItem(value: w, child: Text(w['wallet_name'] ?? 'Wallet')))
              .toList(),
          onChanged: (v) => ss(() => to = v!),
          validator: (v) => v == null ? "Select destination wallet" : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: amt,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: _inputField('Amount', currency: true),
          autofillHints: const[],
          validator: (v) {
            final p = double.tryParse(v ?? '');
            return (p == null || p <= 0) ? "Enter a valid amount" : null;
          },
        ),
      ],
    );
  }

  // --- UI Style Helpers ---
  
  Widget _buildSectionHeader(String title) => Text(title, 
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText));

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: AppColors.primaryText),
      label: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.primaryText)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.cardBg, 
    borderRadius: BorderRadius.circular(15), 
    border: Border.all(color: AppColors.borderColor)
  );

  InputDecoration _inputField(String label, {bool currency = false}) => InputDecoration(
    filled: true,
    fillColor: AppColors.background,
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.w500),
    errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    prefixText: currency ? '₱ ' : null,
    prefixStyle: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w500),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryText, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
  );
}