import 'package:flutter/material.dart';
//import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/pages/dashboard.dart';
import 'package:upesov/features/pages/wallets.dart';
import 'package:upesov/features/pages/budget.dart';
import 'package:upesov/features/pages/manage.dart';
import 'package:upesov/features/pages/login_page.dart';

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
          Image.asset('lib/assets/logo_glow.png', width: 70),
          const SizedBox(width: 15),
          Container(height: 40, width: 1, color: Colors.white24),
          const SizedBox(width: 20),
          const Text(
            'UPesoV',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 40),

          //==== NAV LINKS ====
          Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _navLink(context, "DASHBOARD", DashboardPage()),
                      _navLink(context, "WALLETS", WalletsPage()),
                      _navLink(context, "MANAGE", ManagePage()),
                      _navLink(context, "BUDGET", BudgetPage()),
                    ],
                  ),
                ),
              ),

          const Spacer(),
          //==== PROFILE & LOG OUT ====
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Profile Icon
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              
              // Log Out Text Button
              TextButton(
                onPressed: () async {
                  try {
                    // 1. Tell Supabase to clear the current user session
                    await Supabase.instance.client.auth.signOut();
                    
                    // 2. Safely route the user back to the login screen
                    if (context.mounted) {Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      // Change 'LoginPage()' to whatever your login screen class is named!
                      builder: (context) => const LoginPage(), 
                    ),
                  );
                }
                  } catch (error) {
                    // Fallback UI alert if things go wrong (e.g. network disconnect)
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error logging out: $error')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          )
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
          // ---- pushReplacement to not create an infinite "back" stack on web ----
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
