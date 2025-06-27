import 'package:flutter/material.dart';
import 'package:flutter_application/routes/app_routes.dart';
import 'package:flutter_application/screens/forgot_password_screen.dart';
import 'package:flutter_application/screens/menu_screen.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSignupForm(context),
              const SizedBox(height: 50),
              _buildSocialLoginSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 375,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3FA34D), Color(0xFF4C5D4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(90),
          bottomLeft: Radius.circular(100),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.4 * 255).round()),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _inputField(
              controller: _nameController,
              icon: Icons.person_outline,
              hintText: 'Full Name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a full name';
                }
                if (value.length < 4) {
                  return 'Full name must be at least 4 characters';
                }
                final namePattern = RegExp(r'^[A-Za-zÀ-ÿ]+( [A-Za-zÀ-ÿ]+)?$');
                if (!namePattern.hasMatch(value.trim())) {
                  return 'Name must contain only letters and at most one space.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _inputField(
              controller: _emailController,
              icon: Icons.email_outlined,
              hintText: 'Email',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _inputField(
              controller: _phoneController,
              icon: Icons.phone_outlined,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a phone number';
                }
                final phone = value.trim();
                // Accept only 8 digits or valid Tunisian number
                final tunisianPattern = RegExp(r'^(\+216)?[2-9][0-9]{7}$');
                if (!tunisianPattern.hasMatch(phone)) {
                  return 'Enter a valid Tunisian phone number (8 digits or +216XXXXXXXX)';
                }
                // Use phone_numbers_parser for more robust validation
                try {
                  final parsed = PhoneNumber.parse(
                    phone,
                    callerCountry: IsoCode.TN,
                  );
                  if (!parsed.isValid()) {
                    return 'Invalid Tunisian phone number';
                  }
                } catch (_) {
                  return 'Invalid phone number format';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _inputField(
              controller: _passwordController,
              icon: Icons.lock_outline,
              hintText: 'Password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                // Strong password: min 8 chars, upper, lower, digit, special char
                final strongRegex = RegExp(
                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~_\-]).{8,}$',
                );
                if (!strongRegex.hasMatch(value)) {
                  return 'Password must be at least 8 chars, include upper, lower, digit, and special char.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _inputField(
              controller: _confirmPasswordController,
              icon: Icons.lock_outline,
              hintText: 'Confirm Password',
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () => _handleRegister(
                          context,
                        ), // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 110,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          // Show loader when _isLoading is true
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF41B47D),
                            ),
                          ),
                        )
                        : const Text(
                          // Show text otherwise
                          'Register',
                          style: TextStyle(
                            color: Color(0xFF41B47D),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(BuildContext context) {
    return Container(
      width: 375,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5FFE5), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(60),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).round()),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRoutes.signin);
            },
            child: RichText(
              text: TextSpan(
                text: "Already have an account? ",
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
                children: const [
                  TextSpan(
                    text: "Sign In",
                    style: TextStyle(
                      color: Color(0xFF3FA34D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    dynamic iconData, {
    bool isIcon = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.3 * 255).round()),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child:
            isIcon
                ? Icon(
                  iconData as IconData,
                  size: 24,
                  color: const Color(0xFF4C5D4D),
                )
                : SvgPicture.asset(iconData as String, height: 24, width: 24),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF47CF38)),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(fontSize: 11, color: Colors.orangeAccent),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      String username = _nameController.text.trim();
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String phoneNumber = _phoneController.text.trim();
      debugPrint("Register Attempt:\nUsername: $username\nPassword: $password");

      try {
        final registrationSuccess = await _authService.register(
          username,
          phoneNumber,
          email,
          password,
        );

        if (!mounted) return;

        if (registrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful!"),
              backgroundColor: Colors.green,
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MenuScreen() ,
                ),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Failed: Email might be taken ."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error during registration: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("An error occurred: Please try again later."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please correct the errors above."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      debugPrint("Registration validation failed");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
