import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:upesov/providers/wallet_provider.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  
  @override
  void initState() {
    super.initState();
    // Fetch live data from Supabase immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider - this is your single source of truth
    final walletProvider = context.watch<WalletProvider>();
    final wallets = walletProvider.wallets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'WALLETS'),
      body: walletProvider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryText))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== LEFT AREA (75%) =====
                  Expanded(
                    flex: 2,
                    child: _buildMainContent(wallets, walletProvider.totalBalance),
                  ),
                  const SizedBox(width: 24),

                  // ===== RIGHT AREA (25%) =====
                  Expanded(
                    flex: 1,
                    child: _buildSidebar(),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMainContent(List<Map<String, dynamic>> wallets, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Total Summary"),
          const SizedBox(height: 16),
          
          // The Big Total Balance Card
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
                Text('₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader("My Active Wallets"),
          const SizedBox(height: 16),

          // THE FIX: If empty, show nothing or a message. Otherwise, show ONLY DB wallets.
          wallets.isEmpty 
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No wallets registered yet.", 
                  style: TextStyle(color: AppColors.secondaryText, fontStyle: FontStyle.italic)),
              )
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: wallets.map((w) => _buildWalletCard(w)).toList(),
              ),
          
          const SizedBox(height: 40),
          _buildSectionHeader("Wallet Management Tools"),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildActionButton(Icons.account_balance_wallet, "Add Wallet", () {
                 // Future logic for adding more wallets
              }),
              const SizedBox(width: 12),
              _buildActionButton(Icons.add_card, "Add Money", () {}),
              const SizedBox(width: 12),
              _buildActionButton(Icons.swap_horiz, "Transfer Money", () {}),
            ],
          ),
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
          Text("₱${(wallet['wallet_balance'] ?? 0.0).toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Recent Activity Logs"),
          const SizedBox(height: 16),
          const Expanded(child: Center(child: Text('No activity logs found.', 
            textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.secondaryText)))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText));

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

  BoxDecoration _cardDecoration() => BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.borderColor));
}