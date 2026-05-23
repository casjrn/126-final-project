import 'package:flutter/material.dart';
//import 'package:flutter/gestures.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
//import 'package:upesov/features/pages/login_page.dart';
//import 'package:upesov/features/pages/setup_page.dart';
import 'package:flutter/widget_previews.dart';

  //preview of dashboard page layout
  @Preview(name: 'Dashboard Layout Preview')
  Widget previewDashboard() {
    return DashboardPage();
  }

  class DashboardPage extends StatefulWidget{
    const DashboardPage({super.key});

    @override
    State<DashboardPage> createState() => _DashboardPageState();

  //===== FRONTEND =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'DASHBOARD'), 
      body: Row(
        children: [
          
        ],
      )
    );

  }




/*
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CustomNavBar(currentPage: 'DASHBOARD'), 
      
    );
  }
}*/