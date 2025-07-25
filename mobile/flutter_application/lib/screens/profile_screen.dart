import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/screens/edit_profile_screen.dart';
import 'package:flutter_application/screens/auth/login_screen.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> _userFuture;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _userFuture = _getUserData();
  }

  Future<User?> _getUserData() async {
    final authService = AuthService();
    return await authService.getUserData();
  }

  Future<void> _navigateToEditProfile(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
    );
    if (result == true) {
      setState(() {
        _userFuture = _getUserData();
      });
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible && !_isVisible) {
      _isVisible = true;
      setState(() {
        _userFuture = _getUserData();
      });
    } else if (!visible && _isVisible) {
      _isVisible = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('profile-screen-visibility'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<User?>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No user data found.'));
            }
            final user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 30),
                  _buildInfoSection(user),
                  const SizedBox(height: 40),
                  _buildActionButtons(context, user),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFE5FFE5),
          child: Icon(Icons.person, size: 60, color: Color(0xFF3FA34D)),
        ),
        const SizedBox(height: 15),
        Text(
          user?.name ?? '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C5D4D),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(User? user) {
    return Column(
      children: [
        _buildInfoTile(
          Icons.phone_outlined,
          'Phone Number',
          user?.phoneNumber ?? '',
        ),
        _buildInfoTile(Icons.email, 'Email', user?.email ?? ''),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF47CF38)),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, User? user) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            if (user != null) {
              _navigateToEditProfile(user);
            }
          },
          icon: const Icon(
            Icons.edit_outlined,
            size: 20,
            color: Color(0xFF41B47D),
          ),
          label: const Text(
            'Edit Profile',
            style: TextStyle(color: Color(0xFF41B47D), fontSize: 17),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF41B47D),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Color(0xFFE5FFE5)),
            ),
            elevation: 2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C5D4D), Color(0xFF3FA34D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              AuthService().logout();
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, size: 20, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
