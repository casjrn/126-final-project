import 'package:flutter/material.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'DASHBOARD'), 
      body: const Center(
        child: Text(
          'Dashboard Placeholder',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
