import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upesov/features/pages/signup_page.dart';
import 'package:upesov/theme/upesov_theme.dart';
import 'package:upesov/services/supabase_auth_service.dart'; 
import 'package:upesov/features/pages/dashboard.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Hook up your architecture's shared service
  final AuthService _authService = AuthService();
  
  bool _isObscured = true;
  bool _isLoading = false;
  
  // 1. New error state placeholder
  String? _errorMessage;

  Future<void> _login() async {
    // Clear any previous error states when a new attempt begins
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Connect to unified logic layer
      await _authService.logIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Guard statement protects against context unmounting failures
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } on AuthException catch (error) {
      _updateError(error.message);
    } catch (error) {
      _updateError("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Updated error handling helper method
  void _updateError(String message) {
    setState(() => _errorMessage = message);
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
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Side: Logo
                Expanded(
                  flex: 1,
                  child: Container(
                    color: AppColors.navGreen,
                    child: Center(
                      child: Image.asset(
                        'lib/assets/logo_glow.png',
                        width: 450,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Right Side: Login Form
                Expanded(
                  flex: 1,
                  child: Container(
                    color: AppColors.darkGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'UPesoV',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        _buildGoogleButton(),
                        const SizedBox(height: 30),
                        _buildDivider(),
                        const SizedBox(height: 30),
                        _buildLabel("Email address"),
                        const SizedBox(height: 8),
                        _buildTextField(_emailController, 'Email address'),
                        const SizedBox(height: 20),
                        _buildLabel("Password"),
                        const SizedBox(height: 8),
                        _buildPasswordField(),
                        
                        // 3. Conditional injection layout below password field
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 15),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.redAccent[100], // Soft, non-blinding red
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        _buildLoginButton(),
                        const SizedBox(height: 20),
                        _buildSignUpRedirect(),
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

  // Helpers
  Widget _buildLabel(String text) => Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));
  Widget _buildGoogleButton() => SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text('Continue with Google'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15))));
  Widget _buildDivider() => const Row(children: [Expanded(child: Divider(color: Colors.grey)), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or", style: TextStyle(color: Colors.grey))), Expanded(child: Divider(color: Colors.grey))]);
  Widget _buildLoginButton() => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: AppColors.navFocus, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Log in', style: TextStyle(fontWeight: FontWeight.bold))));
  Widget _buildSignUpRedirect() => Text.rich(TextSpan(text: "Don't have an account yet? ", style: const TextStyle(color: Colors.white), children: [TextSpan(text: 'Sign up', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage())))]));
  Widget _buildTextField(TextEditingController controller, String hint) => TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: _inputDecoration(hint));
  Widget _buildPasswordField() => TextField(controller: _passwordController, obscureText: _isObscured, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Password').copyWith(suffixIcon: IconButton(icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _isObscured = !_isObscured))));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)));
}