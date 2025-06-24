import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/sensor.dart';
import 'package:flutter_application/services/sensor_service.dart';
import 'package:intl/intl.dart';

class SensorScreen extends StatefulWidget {
  final String? pumpId;
  const SensorScreen({Key? key, this.pumpId}) : super(key: key);

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final AbstractSensorService _sensorService = SensorService();
  List<Sensor> _readings = [];
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadReadings() async {
    setState(() => _loading = true);
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      0,
      0,
      0,
    );
    final endOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      23,
      59,
      59,
    );
    final readings = await _sensorService.getSensorsByDate(
      startDate: startOfDay,
      endDate: endOfDay,
    );
    setState(() {
      _readings =
          readings.where((r) {
            if (widget.pumpId != null) {
              return (r.pumpId ?? '') == widget.pumpId;
            }
            return true;
          }).toList();
      _loading = false;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadReadings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text('Sensor Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReadings,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadReadings,
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _readings.isEmpty
                      ? const Center(child: Text('No sensor data found.'))
                      : ListView.builder(
                        itemCount: _readings.length,
                        itemBuilder: (context, index) {
                          final r = _readings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              child: Row(
                                children: [
                                  // Icon or colored circle for temperature
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.shade50,
                                    ),
                                    child: const Icon(
                                      Icons.sensors,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Sensor values
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.thermostat,
                                              size: 18,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${r.temperature.toStringAsFixed(1)}°C',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(
                                              Icons.water_drop,
                                              size: 18,
                                              color: Colors.blueAccent,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${r.humidity.toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(
                                              Icons.grass,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${r.waterCapacity.toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat(
                                                'yyyy-MM-dd HH:mm:ss',
                                              ).format(
                                                r.timestamp ?? DateTime.now(),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
