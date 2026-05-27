import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
                        Container(padding: EdgeInsets.all(16.0),
                        child: const Text(
                          'Hello, User!',
                          style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,  
                            ),
                          ),
                        ),

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
                    child: Column(
                    children:[ 
                      const SizedBox(width: 12),
                      _buildActionButton(Icons.add_card, "Add Money", () {}),
                      const SizedBox(height: 35),
                      _buildQuickSelectSidebar(), 
                      ],
                    )

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
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [

          // ===== SPENDING SUMMARY =====
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [

                      // PIE CHART
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 0,
                            sections: [
                              PieChartSectionData(
                                value: 55,
                                color: Colors.deepPurple,
                                radius: 60,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 25,
                                color: Colors.lightGreenAccent,
                                radius: 60,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 15,
                                color: Colors.pinkAccent,
                                radius: 60,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 5,
                                color: Colors.white,
                                radius: 60,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // LEGEND
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Food: ₱500', style: TextStyle(color: AppColors.primaryText),),
                          SizedBox(height: 10),
                          Text('Transport: ₱250', style: TextStyle(color: AppColors.primaryText),),
                          SizedBox(height: 10),
                          Text('School: ₱150', style: TextStyle(color: AppColors.primaryText),),
                          SizedBox(height: 10),
                          Text('Others: ₱50', style: TextStyle(color: AppColors.primaryText),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ===== SAVINGS SUMMARY =====
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [

                      // DONUT CHART
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 20,
                            sections: [
                              PieChartSectionData(
                                value: 55,
                                color: Colors.deepPurple,
                                radius: 55,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 25,
                                color: Colors.lightGreenAccent,
                                radius: 55,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 15,
                                color: Colors.pinkAccent,
                                radius: 55,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                value: 5,
                                color: Colors.white,
                                radius: 55,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // SAVINGS DETAILS
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Saved:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('₱5,000', style: TextStyle(color: AppColors.primaryText),),

                          SizedBox(height: 20),

                          Text(
                            'Target Amount:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('₱10,000', style: TextStyle(color: AppColors.primaryText),),
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

  
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: const Color.fromARGB(255, 255, 255, 255)),
      label: Text(label, style: const TextStyle(fontSize: 25, color: Color.fromARGB(255, 255, 255, 255))),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.navGreen,
        side: const BorderSide(color: AppColors.borderColor),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}