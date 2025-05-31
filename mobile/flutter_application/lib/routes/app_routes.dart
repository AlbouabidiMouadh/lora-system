import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/screens/auth/reset_password_page.dart';
import 'package:flutter_application/screens/home_screen.dart';
import 'package:flutter_application/screens/forgot_password_screen.dart';
import 'package:flutter_application/screens/logoscreen.dart';
import 'package:flutter_application/screens/map_screen.dart';
import 'package:flutter_application/screens/login_screen.dart';
import 'package:flutter_application/screens/menu_screen.dart';
import 'package:flutter_application/screens/register_screen.dart';
import 'package:flutter_application/screens/screen_splash.dart';
import 'package:flutter_application/services/auth_service.dart';
import 'package:flutter_application/screens/edit_profile_screen.dart';
import 'package:flutter_application/screens/change_password_screen.dart';

class AppRoutes {
  static const String splash = "/";
  static const String signin = "/signin";
  static const String home = "/home";
  static const String menu = "/menu";
  static const String signup = "/signup";
  static const String profile = "/profile";
  static const String settings = "/settings";
  static const String about = "/about";
  static const String map = "/map";
  static const String logo = "/logo";
  static const String resetPassword = '/reset-password';
  static const String forgotPassword = "/forgot_password";
  static const String editProfile = '/edit_profile';
  static const String changePassword = '/change_password';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      menu:
          (context) => const MenuScreen(), // Remplacez par votre écran de menu
      signin: (context) => const LoginScreen(),
      signup: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      resetPassword: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        final token = args?['resettoken'] as String?;
        if (token == null) {
          return const Scaffold(body: Center(child: Text('Token manquant')));
        }
        return ResetPasswordPage(token: token);
      },
      splash: (context) => const SplashScreen(),
      logo: (context) => const Logoscreen(),
      home: (context) => const HomeScreen(),
      map: (context) => const MapScreen(),
      editProfile: (context) {
        final user =
            ModalRoute.of(context)!.settings.arguments as User?;
        return EditProfileScreen(user: user);
      },
      changePassword: (context) => const ChangePasswordScreen(),
    };
  }

  // Vérifier si l'utilisateur est connecté et rediriger en conséquence
  static Future<String> getInitialRoute() async {
    final AuthService authService = AuthService();
    final bool isLoggedIn = await authService.isLoggedIn();
    return isLoggedIn ? menu : signin;
  }
}
