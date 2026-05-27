import 'package:flutter/material.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Dashboard Layout Preview')
Widget previewDashboard() {
  return const DashboardPage();
}
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Mock data structural setup mapping to your balance rules
  final List<Map<String, dynamic>> _myWallets = [
    {'name': 'Cash', 'balance': 0.00, 'type': 'Cash'},
    {'name': 'GCash', 'balance': 0.00, 'type': 'GCash'},
  ];

  // Live getter to securely evaluate balance values without mutation risk
  double get totalBalance => _myWallets.fold(0.0, (sum, item) => sum + item['balance']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'DASHBOARD'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== LEFT AREA: DASHBOARD TRACKING CONTENT (75% Width) =====
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalSummaryCard(),
                    const SizedBox(height: 24),
                    _buildWalletsSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // ===== RIGHT AREA: QUICK SELECT SIDEBAR (25% Width) =====
              Expanded(
                flex: 1,
                child: _buildQuickSelectSidebar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== LEFT SIDE BUILDERS =====

  Widget _buildTotalSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Balance', '₱${totalBalance.toStringAsFixed(2)}', AppColors.primaryText),
          _buildVerticalDivider(),
          _buildSummaryItem('Income', '₱0.00', Colors.green),
          _buildVerticalDivider(),
          _buildSummaryItem('Expenses', '₱0.00', Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.secondaryText, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.borderColor,
    );
  }

  Widget _buildWalletsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Wallets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: _myWallets.map((wallet) => _buildWalletCard(wallet)).toList(),
        ),
      ],
    );
  }

  Widget _buildWalletCard(Map<String, dynamic> wallet) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            wallet['type'] == 'GCash' ? Icons.account_balance_wallet : Icons.money,
            color: AppColors.infoContainer1,
            size: 28,
          ),
          const SizedBox(height: 16),
          Text(
            wallet['name'],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(height: 4),
          Text(
            '₱${wallet['balance'].toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildActionButton('Add Wallet', Icons.add_card, () {})),
        const SizedBox(width: 16),
        Expanded(child: _buildActionButton('Add Money', Icons.add_circle_outline, () {})),
        const SizedBox(width: 16),
        Expanded(child: _buildActionButton('Transfer Money', Icons.swap_horiz, () {})),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.black),
      label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.infoContainer1,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  // ===== RIGHT SIDE BUILDER (QUICK SELECT SIDEBAR) =====

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
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildQuickSelectItem('Trike Fare', '₱15.00', Icons.directions_bike),
                _buildQuickSelectItem('Vnyrd Combo Meal', '₱85.00', Icons.fastfood),
                _buildQuickSelectItem('Jeepney Fare', '₱13.00', Icons.directions_bus),
                _buildQuickSelectItem('Photocopy', '₱5.00', Icons.print),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectItem(String title, String cost, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryText, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              cost,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.infoContainer1),
            ),
          ],
        ),
      ),
    );
  }
}
