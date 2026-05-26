import 'package:flutter/material.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/pages/landing_page.dart';
void main() {
  runApp(const MyApp());
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

