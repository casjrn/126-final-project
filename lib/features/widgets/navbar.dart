import 'package:flutter/material.dart';
//import 'package:flutter/gestures.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/pages/dashboard.dart';
import 'package:upesov/features/pages/wallets.dart';
import 'package:upesov/features/pages/budget.dart';
import 'package:upesov/features/pages/manage.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;
  const CustomNavBar({super.key, required this.currentPage});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.navGreen,
      child: Row(
        children: [

          //==== LOGO & TITLE ====
          Image.asset('assets/logo_glow.png', width: 50),
          const SizedBox(width: 15),
          Container(height: 40, width: 1, color: Colors.white24),
          const SizedBox(width: 20),
          const Text(
            'UPesoV',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 40),

          //==== NAV LINKS ====
          _navLink(context, "DASHBOARD", DashboardPage()),
          _navLink(context, "WALLETS", WalletsPage()),
          _navLink(context, "MANAGE", ManagePage()),
          _navLink(context, "BUDGET", BudgetPage()),

          const Spacer(),
          //==== PROFILE & LOG OUT ====
        ],
      ),
    );
  }

  //==== NAVIGATION LOGIC ====
  Widget _navLink(BuildContext context, String title, Widget destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: () {
          // Use pushReplacement so you don't create an infinite "back" stack on web
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Text(
          title,
          style: TextStyle(
            color: currentPage == title ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: currentPage == title ? FontWeight.bold : FontWeight.w400,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}