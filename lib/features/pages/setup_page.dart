import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upesov/features/pages/login_page.dart';
import 'package:upesov/features/pages/dashboard.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/services/wallet_service.dart';
import 'package:upesov/services/goal_service.dart';

class SetUpPage extends StatefulWidget {
  const SetUpPage({super.key});

  @override
  State<SetUpPage> createState() => _SetUpPageState();
}

class _SetUpPageState extends State<SetUpPage> {
  // Controllers for the input fields
  final _balanceController = TextEditingController();
  final _savingsController = TextEditingController();

  // Instantiate the specialized services
  final WalletService _walletService = WalletService();
  final GoalService _goalService = GoalService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSetupSubmit() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    // Validation
    if (user == null) {
      setState(() => _errorMessage = "User not found. Please log in again.");
      return;
    }

    final balanceText = _balanceController.text.trim();
    final savingsText = _savingsController.text.trim();

    if (balanceText.isEmpty || savingsText.isEmpty) {
      setState(() => _errorMessage = "Both fields are required.");
      return;
    }

    final balance = double.tryParse(balanceText);
    final savings = double.tryParse(savingsText);

    if (balance == null || savings == null) {
      setState(() => _errorMessage = "Please enter valid numbers.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // COORDINATION: Call both services
      await _walletService.createInitialWallet(userId: user.id, balance: balance);
      await _goalService.createInitialGoal(userId: user.id, target: savings);

      if (!mounted) return;

      // SUCCESS: Move to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on PostgrestException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: Row(
        children: [
          // Left Side: Branding
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.navGreen,
              child: Center(
                child: Image.asset('lib/assets/logo_glow.png', width: 450),
              ),
            ),
          ),
          // Right Side: Form
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('UPesoV', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 40),
                  const Text(
                    "Set-up your cash balance and desired savings amount per week.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 30),
                  _buildLabel("How much cash do you have in your physical wallet?"),
                  _buildNumericField(_balanceController, '0.00'),
                  const SizedBox(height: 20),
                  _buildLabel("How much do you want to save per week?"),
                  _buildNumericField(_savingsController, '0.00'),
                  
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 15),
                    Text(_errorMessage!, style: TextStyle(color: Colors.redAccent[100])),
                  ],
                  
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );

  Widget _buildNumericField(TextEditingController controller, String hint) => Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(hint),
    ),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleSetupSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navFocus,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: _isLoading 
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
        : const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildLoginLink() => Text.rich(
    TextSpan(
      text: "Already have an account? ",
      style: const TextStyle(color: Colors.white),
      children: [
        TextSpan(
          text: 'Log In',
          style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          },
        ),
      ],
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)),
  );
}