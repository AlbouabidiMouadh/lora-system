import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;
  const EditProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.user?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      final updated = await authService.updateDetails(
        widget.user?.id ?? '',
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );
      if (updated['success'] == true) {
        widget.user?.name = _nameController.text.trim();
        widget.user?.phoneNumber = _phoneController.text.trim();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updated['message'] ?? 'Failed to update profile.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Container(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _inputField(
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hintText: 'Name',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Name is required'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _inputField(
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hintText: 'Phone Number',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Phone number is required'
                                : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF3FA34D),
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
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
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF47CF38)),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 11, color: Colors.orangeAccent),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}
