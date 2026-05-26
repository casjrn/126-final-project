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
  
  // Inject the service
  final AuthService _authService = AuthService();
  
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;

  // New inline error state tracker
  String? _errorMessage;

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _updateError("Passwords do not match!");
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Reset state for a fresh attempt
    });

    try {
      // Call the external service
      final user = await _authService.signUpAndCreateProfile(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
      );

      // If successful, navigate
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SetUpPage()),
        );
      }
    } on PostgrestException catch (dbError) {
      debugPrint("DATABASE ERROR: ${dbError.message}");
      debugPrint("ERROR CODE: ${dbError.code}");
      debugPrint("ERROR DETAILS: ${dbError.details}");
      _updateError("Database Error: ${dbError.message}");
    } on AuthException catch (authError) {
      debugPrint("AUTH ERROR: ${authError.message}");
      _updateError(authError.message);
    } catch (e) {
      debugPrint("GENERAL ERROR: $e");
      _updateError("Unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Update logic to set local error state text string
  void _updateError(String message) {
    setState(() => _errorMessage = message);
  }

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

                // Right Side: Form
                Expanded(
                  flex: 1,
                  child: Container(
                    color: AppColors.darkGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('UPesoV', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 40),
                        _buildGoogleButton(),
                        const SizedBox(height: 25),
                        _buildDivider(),
                        const SizedBox(height: 25),
                        _buildLabel("Email address"),
                        const SizedBox(height: 8),
                        _buildTextField(_emailController, 'Email address'),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Password"), const SizedBox(height: 8), _buildPasswordField(controller: _passwordController, isObscured: _isObscured, onToggle: () => setState(() => _isObscured = !_isObscured))])),
                            const SizedBox(width: 20),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Confirm Password"), const SizedBox(height: 8), _buildPasswordField(controller: _confirmPasswordController, isObscured: _isConfirmObscured, onToggle: () => setState(() => _isConfirmObscured = !_isConfirmObscured))])),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildLabel("Username"),
                        const SizedBox(height: 8),
                        _buildTextField(_usernameController, 'Username'),
                        
                        // Conditional injection layout safely nestled below the final input field
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 15),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.redAccent[100], // Soft, aesthetic red
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
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

  // Helpers
  Widget _buildLabel(String text) => Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));
  Widget _buildGoogleButton() => SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, size: 30), label: const Text('Continue with Google'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300], foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(vertical: 15))));
  Widget _buildDivider() => const Row(children: [Expanded(child: Divider(color: Colors.grey)), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or", style: TextStyle(color: Colors.grey))), Expanded(child: Divider(color: Colors.grey))]);
  Widget _buildNextButton() => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _signUp, style: ElevatedButton.styleFrom(backgroundColor: AppColors.navFocus, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Next', style: TextStyle(fontWeight: FontWeight.bold))));
  Widget _buildLoginRedirect() => Text.rich(TextSpan(text: "Already have an account? ", style: const TextStyle(color: Colors.white), children: [TextSpan(text: 'Log In', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => Navigator.pop(context))]));
  Widget _buildTextField(TextEditingController controller, String hint) => TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: _inputDecoration(hint));
  Widget _buildPasswordField({required TextEditingController controller, required bool isObscured, required VoidCallback onToggle}) => TextField(controller: controller, obscureText: isObscured, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Password').copyWith(suffixIcon: IconButton(icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onToggle)));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)));
}