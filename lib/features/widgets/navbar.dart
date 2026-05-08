import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:upesov/theme/upesov_theme.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;
  const CustomNavBar({super.key, required this.currentPage});

  @override
  // This tells the Scaffold how much space the navbar needs
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.navGreen,
      child: Row(
        children: [
          Image.asset('assets/logo_glow.png', width: 50),
          const SizedBox(width: 15),
          Container(height: 40, width: 1, color: Colors.white24),
          const SizedBox(width: 20),
          const Text(
            'UPesoV',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Add your Nav Links here
        ],
      ),
    );
  }
}