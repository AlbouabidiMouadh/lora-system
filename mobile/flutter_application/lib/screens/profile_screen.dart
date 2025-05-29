import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final String userName = "Flutter Dev";
  final String userEmail = "developer@example.com";
  final String profileImageUrl = 'assets/avatar.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildInfoSection(),
            const SizedBox(height: 40),
            _buildActionButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFE5FFE5),

          child: Icon(Icons.person, size: 60, color: Color(0xFF3FA34D)),
        ),
        const SizedBox(height: 15),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C5D4D),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          userEmail,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoTile(Icons.phone_outlined, 'Phone Number', '+1 234 567 890'),
        _buildInfoTile(Icons.location_on_outlined, 'Location', 'City, Country'),
        _buildInfoTile(Icons.work_outline, 'Role', 'App Developer'),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF47CF38)),
      title: Text(title, style: TextStyle(color: Colors.grey[800])),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            debugPrint("Edit Profile Tapped");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Edit Profile page not implemented yet."),
              ),
            );
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
              debugPrint("Logout Tapped");
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (route) => false,
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
