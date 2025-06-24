import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/home_screen.dart';
import 'package:flutter_application/screens/map_screen.dart';
import 'package:flutter_application/screens/profile_screen.dart';
import 'package:flutter_application/screens/settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (index) => GlobalKey<NavigatorState>(),
  );

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If re-tapping the same tab, pop to first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  bool _onWillPop()  {
    final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
    if (currentNavigator?.canPop() == true) {
      currentNavigator?.pop();
      return true;
    }
    if (_selectedIndex == 0) {
    
      return false;
    }
    return true; // Allow exit if on the first tab and no more routes to pop
   // Allow exit if on the first tab and no more routes to pop
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _onWillPop(),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(0, const HomeScreen()),
            _buildTabNavigator(1, const MapScreen()),
            _buildTabNavigator(2, const ProfileScreen()),
            _buildTabNavigator(3, const SettingsScreen()),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF3FA34D),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute:
          (settings) => MaterialPageRoute(
            builder: (context) => child,
            settings: settings,
          ),
    );
  }
}
