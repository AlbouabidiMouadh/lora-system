import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  User? _user;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getUserData();
    setState(() {
      _user = user;
      _loadingUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:
          _loadingUser
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  _buildProfileHeader(),
                  _buildSectionTitle('Preferences'),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_outlined,
                        title: 'Push Notifications',
                        value: _notificationsEnabled,
                        onChanged: (bool value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                      const Divider(height: 1, indent: 58),
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        value: _darkModeEnabled,
                        onChanged: (bool value) {
                          setState(() => _darkModeEnabled = value);
                          // TODO: Implement dark mode switching
                        },
                      ),
                      const Divider(height: 1, indent: 58),
                      _buildSettingsTile(
                        context,
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {},
                      ),
                    ],
                  ),
                  _buildSectionTitle('Account'),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.settings_input_component_outlined,
                        title: 'Control',
                        onTap: () {
                          Navigator.pushNamed(context, '/pump_control');
                        },
                      ),
                      const Divider(height: 1, indent: 58),
                      _buildSettingsTile(
                        context,
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {
                          if (_user != null) {
                            Navigator.pushNamed(
                              context,
                              '/edit_profile',
                              arguments: _user,
                            );
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 58),
                      _buildSettingsTile(
                        context,
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () {
                          Navigator.pushNamed(context, '/change_password');
                        },
                      ),
                    ],
                  ),
                  _buildSectionTitle('About'),
                  _buildSettingsCard(
                    children: [
                      _buildSettingsTile(
                        context,
                        icon: Icons.info_outline,
                        title: 'About App',
                        subtitle: 'Version 1.0.0',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 58),
                      _buildSettingsTile(
                        context,
                        icon: Icons.policy_outlined,
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 58),
                      _buildSettingsTile(
                        context,
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
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
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/signin',
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.logout,
                          size: 20,
                          color: Colors.white,
                        ),
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
                  ),
                  const SizedBox(height: 30),
                ],
              ),
    );
  }

  Widget _buildProfileHeader() {
    if (_user == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3FA34D), Color(0xFF4C5D4D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFE5FFE5),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user?.name ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _user?.email ?? '',
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4C5D4D),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF3FA34D)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3FA34D)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}
