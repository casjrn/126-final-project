import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upesov/features/pages/setup_page.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/services/supabase_auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _updateError("Passwords do not match!");
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null; 
    });

    try {
      final user = await _authService.signUpAndCreateProfile(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetUpPage()),
        );
      }
    } on AuthException catch (authError) {
      _updateError(authError.message);
    } catch (e) {
      _updateError("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateError(String message) => setState(() => _errorMessage = message);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: AppColors.navGreen,
                    child: Center(child: Image.asset('lib/assets/logo_glow.png', width: 450)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('UPesoV', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 40),
                        _buildLabel("Email address"),
                        _buildTextField(_emailController, 'Email address'),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: _buildPasswordField(_passwordController, "Password", _isObscured, () => setState(() => _isObscured = !_isObscured))),
                            const SizedBox(width: 20),
                            Expanded(child: _buildPasswordField(_confirmPasswordController, "Confirm Password", _isConfirmObscured, () => setState(() => _isConfirmObscured = !_isConfirmObscured))),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildLabel("Username"),
                        _buildTextField(_usernameController, 'Username'),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 15),
                          Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent[100], fontSize: 14)),
                        ],
                        const SizedBox(height: 30),
                        _buildNextButton(),
                        const SizedBox(height: 20),
                        _buildLoginRedirect(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Unified UI Components
  Widget _buildLabel(String text) => Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));
  
  Widget _buildTextField(TextEditingController controller, String hint) => Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: _inputDecoration(hint)),
  );

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscured, VoidCallback toggle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel(label),
      const SizedBox(height: 8),
      TextField(
        controller: controller, 
        obscureText: obscured, 
        style: const TextStyle(color: Colors.white), 
        decoration: _inputDecoration(label).copyWith(suffixIcon: IconButton(icon: Icon(obscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: toggle)),
      ),
    ],
  );

  Widget _buildNextButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _signUp,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.navFocus, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Next', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  );

  Widget _buildLoginRedirect() => Text.rich(TextSpan(text: "Already have an account? ", style: const TextStyle(color: Colors.white), children: [TextSpan(text: 'Log In', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context))]));

  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)));
}