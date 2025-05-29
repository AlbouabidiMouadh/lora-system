import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/logoscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();

  final List<String> leafImages = [
    'assets/le.png',
    'assets/le1.png',
    'assets/le2.png',
    'assets/le3.png',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Démarrage de l’animation après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      _controller.forward();

      // Transition vers l’écran suivant après 7 secondes
      Future.delayed(const Duration(seconds: 7), () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(seconds: 4),
            pageBuilder:
                (context, animation, secondaryAnimation) => const Logoscreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              );
              return FadeTransition(opacity: curvedAnimation, child: child);
            },
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const int leafCount = 130;

    return Scaffold(
      body: Stack(
        children: List.generate(leafCount, (index) {
          final initialX = _random.nextDouble() * screenSize.width;
          final initialY = _random.nextDouble() * screenSize.height;

          final dx = (initialX - screenSize.width / 2) * 1.5;
          final dy = (initialY - screenSize.height / 2) * 1.5;

          final animation = Tween<Offset>(
            begin: Offset(initialX, initialY),
            end: Offset(initialX + dx, initialY + dy),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                left: animation.value.dx,
                top: animation.value.dy,
                child: Image.asset(
                  leafImages[index % leafImages.length],
                  width: 600,
                  height: 600,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
