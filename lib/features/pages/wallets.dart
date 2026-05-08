import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:upesov/features/pages/login_page.dart';
import 'package:upesov/features/pages/setup_page.dart';
import 'package:upesov/theme/upesov_theme.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [

          //navabar bg
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: AppColors.navGreen,
            child: Row(
              children: [
                Image.asset(
                  'lib/assets/logo_glow.png',
                  width: 50,
                  fit: BoxFit.contain,
                ),

              const SizedBox(width: 15),

              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),

              const SizedBox(width: 20),

              const Text(
                'UPesoV',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),

              const Spacer(),
            ],
          ),
          ),

        ],
      ),
    );
  }
}