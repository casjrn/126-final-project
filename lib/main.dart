import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/pages/landing_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upesov/providers/wallet_provider.dart';
import 'package:upesov/providers/goal_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zcmbtclypnsbsxfpfgmk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjbWJ0Y2x5cG5zYnN4ZnBmZ21rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NjQwMDUsImV4cCI6MjA5MTI0MDAwNX0.OXPwbU8omslvmeRX66idiiKZHGQbxPS75T-htLZOEL4',
  );

  // Wrap in MultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPesoV',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.darkGreen,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}