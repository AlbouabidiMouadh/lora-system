import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/routes/app_routes.dart';

class InitialRoute extends StatefulWidget {
  const InitialRoute({super.key});

  @override
  State<InitialRoute> createState() => _InitialRouteState();
}

class _InitialRouteState extends State<InitialRoute> {
  late Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _getInitialRoute();
    _initUniLinks();
  }

  void _initUniLinks() {
    AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    print("Uri : $uri");
    if (uri.host == 'reset-password') {
      final token = uri.queryParameters['resettoken'];
      if (token != null) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.resetPassword, arguments: {'resettoken': token});
      }
    }
  }

  Future<String> _getInitialRoute() async {
    try {
      return await AppRoutes.getInitialRoute().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('Timeout getting initial route, defaulting to login');
          return AppRoutes.signin;
        },
      );
    } catch (e) {
      print('Error getting initial route: $e');
      return AppRoutes.signin; // Default route in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement...'),
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