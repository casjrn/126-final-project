import 'package:flutter/material.dart';
//import 'package:flutter/gestures.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
//import 'package:upesov/features/pages/login_page.dart';
//import 'package:upesov/features/pages/setup_page.dart';
class WalletsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CustomNavBar(currentPage: 'WALLETS'), 

      body: Row(
        children: [
          //Total balance container
          Container(
            width: 550,
            height: 136,
            color: AppColors.infoContainer1,
            child: const Center(
              child: Text(
                'Total Balance: 00.00', // Placeholder for total balance
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          //
        ],
        ),
      
    );
  }
}