import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/login_screen.dart';
import 'package:flutter_application/screens/notification_screen.dart';
import 'package:flutter_application/services/weather_service.dart';
import 'package:flutter_application/utils/api_exception.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:flutter_application/services/fake_pump_service.dart';
import 'package:flutter_application/services/pump_service.dart';
import 'package:flutter_application/models/pump.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = 'Loading...', temperature = '...', description = 'Loading...';
  final AbstractPumpService _pumpService = PumpService();
  List<Pump> _pumps = [];
  Timer? _refreshTimer;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    determinePositionAndGenerateFakeSensor();
    _loadPumps();
    // Do not start timer here; let visibility detector handle it
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final visible = info.visibleFraction > 0.5;
    if (visible && !_isVisible) {
      _isVisible = true;
      _startAutoRefresh();
    } else if (!visible && _isVisible) {
      _isVisible = false;
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _loadPumps();
      }
    });
  }

  Future<void> _loadPumps() async {
    try {
      final pumps = await _pumpService.getAllPumps();
      if (!mounted) return;
      setState(() {
        _pumps = pumps;
      });
    } catch (e) {
      if (!mounted) return;

      if (e is ApiException) {
        if (e.message.contains('expired')) {
          setState(() => description = 'Session expired. Please log in again.');

          Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else if (e.message.contains('not found')) {
          setState(() => description = 'Pumps not found.');
        } else {
          setState(() => description = 'API Error: ${e.message}');
        }
      } else if (e is http.ClientException) {
        setState(() => description = 'Request timed out. Please try again.');
      } else {
        setState(() => description = 'An unexpected error occurred: $e');
      }
    }
  }

  Future<void> determinePositionAndGenerateFakeSensor() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => description = 'Location services disabled.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => description = 'Location permissions denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => description = 'Location permissions permanently denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      fetchWeatherByCoordinates(pos.latitude, pos.longitude);

      // await _fakeSensorService.generateFakePump(pos);
    } catch (e) {
      setState(() => description = 'Error: ${e.toString()}');
    }
  }

  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    final weatherService = WeatherService();
    try {
      final weatherData = await weatherService.getCurrentWeatherByCoordinates(
        lat,
        lon,
      );
      if (!mounted) return;
      setState(() {
        city = weatherData.cityName;
        temperature = '${weatherData.temperature.toStringAsFixed(1)}°C';
        description = weatherData.description;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => description = 'Failed to load weather data: $e');
    }
  }

  void renameStation(Function(String) updateName, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Rename Station'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter new name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  updateName(controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('home-screen-visibility'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3FA34D), Color(0xFF4C5D4D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPumps,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await determinePositionAndGenerateFakeSensor();
              await _loadPumps();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Welcome back !',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const NotificationScreen(),
                              ),
                            ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.notifications, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  WeatherCard(
                    city: city,
                    temperature: temperature,
                    description: description,
                  ),
                  const SizedBox(height: 16),
                  ..._pumps.map((pump) {
                    final lastSensor =
                        (pump.sensors.isNotEmpty)
                            ? pump.sensors.reduce(
                              (a, b) =>
                                  a.timestamp?.isAfter(
                                            b.timestamp ?? DateTime.now(),
                                          ) ??
                                          false
                                      ? a
                                      : b,
                            )
                            : null;
                    return StationCard(
                      stationName: pump.name,
                      temperature:
                          lastSensor != null
                              ? lastSensor.temperature.toStringAsFixed(1)
                              : '...',
                      humidity:
                          lastSensor != null
                              ? lastSensor.humidity.toStringAsFixed(1)
                              : '...',
                      moisture:
                          lastSensor != null
                              ? lastSensor.waterCapacity.toStringAsFixed(1)
                              : '...',
                      lastConnected:
                          lastSensor != null
                              ? lastSensor.timestamp.toString()
                              : 'No data',
                      onRename: (_) {}, // No-op, name is final
                      onTapRename:
                          () => renameStation((_) {}, pump.name), // No-op
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

class WeatherCard extends StatelessWidget {
  final String city, temperature, description;

  const WeatherCard({
    super.key,
    required this.city,
    required this.temperature,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 17,
            offset: Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weather',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Icon(Icons.cloud, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                city,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class StationCard extends StatelessWidget {
  final String stationName, temperature, humidity, moisture, lastConnected;
  final Function(String) onRename;
  final VoidCallback onTapRename;

  const StationCard({
    super.key,
    required this.stationName,
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.lastConnected,
    required this.onRename,
    required this.onTapRename,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      stationName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onTapRename,
                      child: const Icon(Icons.edit, size: 16),
                    ),
                  ],
                ),
                // const Icon(Icons.battery_full, size: 20, color: Colors.green),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DataBox(
                  value: temperature,
                  icon: FontAwesomeIcons.temperatureHigh,
                ),
                DataBox(value: humidity, icon: FontAwesomeIcons.tint),
                DataBox(value: moisture, icon: FontAwesomeIcons.water),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Last connected $lastConnected',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataBox extends StatelessWidget {
  final String value;
  final IconData icon;

  const DataBox({super.key, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(value, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Icon(
            icon,
            size: 18,
            shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ],
      ),
    );
  }
}
