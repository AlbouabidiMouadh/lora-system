import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/dashboard_screen.dart';
import 'package:flutter_application_2/screens/logoscreen.dart';
import 'package:flutter_application_2/screens/map_screen.dart';
import 'package:flutter_application_2/screens/screen_signin.dart';
import 'package:flutter_application_2/screens/screen_signup.dart';
import 'package:flutter_application_2/screens/screen_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Irrigation',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(fontSize: 13, color: Colors.grey),
          bodySmall: TextStyle(fontSize: 13, color: Colors.grey),
          titleLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/logo': (context) => const Logoscreen(),
        'signin': (context) => const Signin(),
        'signup': (context) => const Signup(),
        'home': (context) => const HomeSc(),
        'map': (context) => const SensorDataPage(),
      },
    );
  }
}
