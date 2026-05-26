import 'package:flutter/material.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:flutter/widget_previews.dart';
//import 'package:upesov/features/model/quick_select.dart';
//import 'package:upesov/features/widgets/quickselect_card.dart';

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
          // ===== LEFT AREA: MAIN CONTENT (75% width via flex: 3) =====
          Expanded(
            flex: 3,
            child: SingleChildScrollView( // Prevents UI vertical clipping
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                ],
              ),
            ),
          ),

          // ===== RIGHT AREA: QUICK SELECT CONTAINER (25% width) =====
          Expanded(
            flex: 1, 
            child: Container(
              color: AppColors.infoContainer1,
              padding: const EdgeInsets.all(16.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'UPV Quick Select',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Common UPV purchases',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  
                  // You can easily place your quick select item grids or lists right under here!
                ],
              ),
            ),
          ),

        ],
      )
    );

  }
  }