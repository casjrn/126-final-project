import 'package:flutter/material.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/features/widgets/navbar.dart';
import 'package:upesov/features/model/user_wallets.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Wallets Layout Preview')
Widget previewWallets() {
  return const WalletsPage();
}

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  // Initial active data entries
  final List<UserWallets> _myWallets = [
    UserWallets(name: "GCash", balance: 1500.0, type: "Cash"),
    UserWallets(name: "BPI", balance: 25000.0, type: "Bank Account"),
  ];

  // Dynamic live-state sum calculation expression
  double get _totalBalance {
    return _myWallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }

  // Appends new dynamic entries instantly updating the UI state
  void _addNewWallet() {
    final List<Map<String, String>> presets = [
      {"name": "PayMaya", "type": "Cash"},
      {"name": "Metrobank", "type": "Bank Account"},
      {"name": "Pocket Cash", "type": "Cash"},
    ];
    final selectedPreset = presets[_myWallets.length % presets.length];

    setState(() {
      _myWallets.add(
        UserWallets(
          name: "${selectedPreset['name']} (${_myWallets.length + 1})",
          balance: 0.00,
          type: selectedPreset['type']!,
        ),
      );
    });
  }

  void _addMoney() {
    // ScaffoldMessenger alert action placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Money process initiated')),
    );
  }

  void _transferMoney() {
    // ScaffoldMessenger alert action placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer Money process initiated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(currentPage: 'WALLETS'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== LEFT AREA: MAIN DASHBOARD CONTENT (75%) =====
              Expanded(
                flex: 2,
                child: _buildMainContent(),
              ),
              const SizedBox(width: 24),

              // ===== RIGHT AREA: RECENT LOGS SIDEBAR (25%) =====
              Expanded(
                flex: 1,
                child: _buildSidebar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Building Left Operational UI Structure Block
  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Total Summary"),
          const SizedBox(height: 16),
          
          // Total Balance display card element block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance Across All Wallets',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 8),
                Text(
                  '₱${_totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader("My Active Wallets"),
          const SizedBox(height: 16),

          // Adaptive fluid wrapping multi-column cards grid section
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _myWallets.map((wallet) => _buildWalletCard(wallet)).toList(),
          ),
          const SizedBox(height: 40),

          _buildSectionHeader("Wallet Management Tools"),
          const SizedBox(height: 16),

          // Clean Horizontal Core Operational Control Row Button Row Layout
          Row(
            children: [
              _buildActionButton(Icons.account_balance_wallet, "Add Wallet", _addNewWallet),
              const SizedBox(width: 12),
              _buildActionButton(Icons.add_card, "Add Money", _addMoney),
              const SizedBox(width: 12),
              _buildActionButton(Icons.swap_horiz, "Transfer Money", _transferMoney),
            ],
          ),
        ],
      ),
    );
  }

  // Building Right Recent Log System Sidebar Component Frame
  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Recent Activity Logs"),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(
              child: Text(
                'No recent wallet operations logged today.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Individual Asset Display Grid Unit Layout Block
  Widget _buildWalletCard(UserWallets wallet) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wallet.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            wallet.type,
            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          Text(
            "₱${wallet.balance.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Shared Structural Helper Functions
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: AppColors.primaryText),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, color: AppColors.primaryText),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.borderColor),
    );
  }
}
  
  /*import 'package:flutter/material.dart';
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

  double get _totalBalance {
    return _myWallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }

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
                    margin: const EdgeInsets.only(top: 15.0, bottom: 15.0), // Creates space from the Navbar
                    decoration: BoxDecoration(
                      color: AppColors.infoContainer1,
                      borderRadius: BorderRadius.circular(20.0), // Rounded corners (20px)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15), // Soft subtle shadow
                          blurRadius: 8.0,
                          offset: const Offset(0, 4), // Shifted shadow downwards
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Total Balance: ₱${_totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
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
*/
