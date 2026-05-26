import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upesov/features/pages/signup_page.dart';
import 'package:upesov/features/pages/dashboard.dart'; 
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/services/supabase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.logIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } on AuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (error) {
      setState(() => _errorMessage = "An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(color: AppColors.navGreen, child: Center(child: Image.asset('lib/assets/logo_glow.png', width: 450))),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('UPesoV', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 40),
                  _buildLabel("Email address"),
                  _buildTextField(_emailController, "Email"),
                  const SizedBox(height: 20),
                  _buildLabel("Password"),
                  _buildPasswordField(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 15),
                    Text(_errorMessage!, style: TextStyle(color: Colors.redAccent[100])),
                  ],
                  const SizedBox(height: 30),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  _buildSignUpRedirect(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));

  Widget _buildTextField(TextEditingController controller, String hint) => TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: _inputDecoration(hint));

  Widget _buildPasswordField() => TextField(
    controller: _passwordController,
    obscureText: _isObscured,
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecoration("Password").copyWith(suffixIcon: IconButton(icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _isObscured = !_isObscured))),
  );

  Widget _buildLoginButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.navFocus, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  );

  Widget _buildSignUpRedirect() => Text.rich(TextSpan(text: "Don't have an account? ", style: const TextStyle(color: Colors.white), children: [TextSpan(text: 'Sign Up', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage())))]));

  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)));
}