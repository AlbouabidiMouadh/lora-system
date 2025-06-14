import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_application/routes/app_routes.dart';

class Logoscreen extends StatefulWidget {
  const Logoscreen({super.key});

  @override
  State<Logoscreen> createState() => _LogoscreenState();
}

class _LogoscreenState extends State<Logoscreen> {
   late Future<String> _initialRouteFuture;
  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _getInitialRoute();
  }

  Future<String> _getInitialRoute() async {
    try {
     await Future.delayed(const Duration(seconds: 2));
      return  await  AppRoutes.getInitialRoute().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('Timeout getting initial route, defaulting to login');
          return AppRoutes.signin;
        },
      );
    } catch (e) {
      print('Error getting initial route: $e');
      return AppRoutes.signin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'TECH',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Une erreur est survenue'),
                  Text('${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initialRouteFuture = _getInitialRoute();
                      });
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        final route = snapshot.data ?? AppRoutes.signin;
        return Navigator(
          onGenerateRoute: (settings) {
            final routes = AppRoutes.getRoutes();
            final builder = routes[route];
            if (builder != null) {
              return MaterialPageRoute(builder: builder, settings: settings);
            }
            return MaterialPageRoute(
              builder:
                  (context) => const Scaffold(
                    body: Center(child: Text('Route non trouvée')),
                  ),
            );
          },
        );
      },
    );
  }
}
