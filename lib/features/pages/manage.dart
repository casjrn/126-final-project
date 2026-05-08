import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
//import 'package:upesov/features/pages/login_page.dart';
//import 'package:upesov/features/pages/setup_page.dart';

class ManagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CustomNavBar(currentPage: 'MANAGE'), 
      
    );
  }
}