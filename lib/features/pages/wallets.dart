  import 'package:flutter/material.dart';
  //import 'package:flutter/gestures.dart';
  import 'package:upesov/theme/upesov_theme.dart';
  import 'package:upesov/features/widgets/navbar.dart';
  import 'package:upesov/features/model/user_wallets.dart';
  import 'package:flutter/widget_previews.dart';

//preview of wallets page layout
  @Preview(name: 'Wallets Layout Preview')
  Widget previewWallets() {
    return WalletsPage();
  }

  class WalletsPage extends StatefulWidget{
    const WalletsPage({super.key});

    @override
    State<WalletsPage> createState() => _WalletsPageState();
  }

class _WalletsPageState extends State<WalletsPage> {
  // 2. Initial state configuration holding current data entries
  final List<UserWallets> _myWallets = [
    UserWallets(name: "GCash", balance: 1500.0, type: "Cash"),
    UserWallets(name: "BPI", balance: 25000.0, type: "Bank Account"),
  ];

  // 3. Trigger tracking logic to append objects on command
  void _addNewWallet() {
    setState(() {
      _myWallets.add(
        UserWallets(
          name: "Wallet #${_myWallets.length + 1}",
          balance: 0.0,
          type: "Cash",
        ),
      );
    });
  }

//===== FRONTEND =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'WALLETS'),
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
                  // Total balance container
                  Container(
                    width: 250,
                    height: 100,
                    color: AppColors.infoContainer1,
                    child: const Center(
                      child: Text(
                        'Total Balance: 00.00',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Dynamic Wallets Area populated directly from your list loop
                  const Text(
                    "My Wallets",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 10, 7, 7)),
                  ),
                  
                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 15,    // Horizontal gaps between items
                    runSpacing: 15, // Vertical gaps between implicitly wrapped rows
                    alignment: WrapAlignment.start,
                    children: _myWallets.map((wallet) {
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        child: Container(
                          width: 160, // Grid item sizing boundary
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallet.name, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                wallet.type, 
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "₱${wallet.balance.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // ===== ACTION BUTTONS =====
                  ElevatedButton.icon(
                    onPressed: _addNewWallet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Wallet"),
                  ),

                  /*
                  ElevatedButton.icon(
                    onPressed: _addMoney,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Money"),
                  ),

                  ElevatedButton.icon(
                    onPressed: _transferMoney,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Transfer Money"),
                  ),
                  */


                ],
              ),
            ),
          ),

          // ===== RIGHT AREA: RECENT LOGS CONTAINER (25% width) =====
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: double.infinity,
            color: AppColors.infoContainer1,
            child: const Center(
              child: Text(
                'Recent Logs:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
  class WalletsPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.background,

        appBar: const CustomNavBar(currentPage: 'WALLETS'), 

        body: Row(
          children: [

            //===== MAIN CONTENT =====
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  //Wallets
                  Container(

                  )
                ]
              )
            ),

            Expanded(
              flex: 3,
              child: Column(
                children: [
                  
                ]
              )
            ),

          //Recent logs container
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: double.infinity,
            color: AppColors.infoContainer1,
            child: const Center(
              child: Text(
                'Recent Logs:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            )
          )
          ],
          ),
        
      );
    }
  }*/