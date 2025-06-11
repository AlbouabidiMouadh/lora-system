import 'package:flutter/material.dart';
import 'package:flutter_application/screens/notification_screen.dart';
import 'package:flutter_application/services/weather_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_application/services/fake_pump_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = 'Loading...', temperature = '...', description = 'Loading...';
  String station1Name = 'Station 1', station2Name = 'Station 2';

  Map<String, dynamic>? station1Data, station2Data;
  final FakePumpService _fakeSensorService = FakePumpService();

  @override
  void initState() {
    super.initState();

    determinePositionAndGenerateFakeSensor();
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

      await _fakeSensorService.generateFakePump(pos);
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
      setState(() {
        city = weatherData.cityName;
        temperature = '${weatherData.temperature.toStringAsFixed(1)}°C';
        description = weatherData.description;
      });
    } catch (e) {
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
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: determinePositionAndGenerateFakeSensor,
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
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      )),
                      child:const CircleAvatar(
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
                StationCard(
                  stationName: station1Name,
                  temperature:
                      station1Data?['temperature']?.toStringAsFixed(1) ?? '...',
                  humidity: station1Data?['humidity']?.toString() ?? '...',
                  moisture: station1Data?['moisture']?.toString() ?? '...',
                  lastConnected:
                      station1Data?['timestamp']?.toString() ?? '...',
                  onRename: (name) => setState(() => station1Name = name),
                  onTapRename:
                      () => renameStation(
                        (name) => setState(() => station1Name = name),
                        station1Name,
                      ),
                ),
                const SizedBox(height: 16),
                StationCard(
                  stationName: station2Name,
                  temperature:
                      station2Data?['temperature']?.toStringAsFixed(1) ?? '...',
                  humidity: station2Data?['humidity']?.toString() ?? '...',
                  moisture: station2Data?['moisture']?.toString() ?? '...',
                  lastConnected:
                      station2Data?['timestamp']?.toString() ?? '...',
                  onRename: (name) => setState(() => station2Name = name),
                  onTapRename:
                      () => renameStation(
                        (name) => setState(() => station2Name = name),
                        station2Name,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
                const Icon(Icons.battery_full, size: 20, color: Colors.green),
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
