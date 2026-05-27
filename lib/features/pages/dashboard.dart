import 'package:flutter/material.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Dashboard Layout Preview')
Widget previewDashboard() {
  return const DashboardPage();
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                  // ===== LEFT AREA: DASHBOARD TRACKING CONTENT (75% Width) =====
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalSummaryCard(),
                        const SizedBox(height: 24),
                        _buildAnalyticsSection(),
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
          );
        },
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
          Expanded(child: _buildSummaryItem('Total Balance', '₱0.00', AppColors.primaryText)),
          _buildVerticalDivider(),
          Expanded(child: _buildSummaryItem('Expenses', '₱0.00', AppColors.primaryText)),
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
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.borderColor,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildAnalyticsSection() {
    return Container(
      width: double.infinity,
      height: 380, // Expanded height to prioritize the chart layout space nicely
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Analytics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visual breakdown of weekly spending trends',
            style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
          ),
          const Expanded(
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

  // ===== RIGHT AREA (QUICK SELECT SIDEBAR) =====

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
              _buildQuickSelectItem('Trike Fare', '₱15.00', Icons.directions_bike),
              _buildQuickSelectItem('Vnyrd Combo Meal', '₱85.00', Icons.fastfood),
              _buildQuickSelectItem('Jeepney Fare', '₱13.00', Icons.directions_bus),
              _buildQuickSelectItem('Photocopy', '₱5.00', Icons.print),
            ],
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