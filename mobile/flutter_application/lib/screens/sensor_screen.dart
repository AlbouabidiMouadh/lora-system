import 'package:flutter/material.dart';
import 'package:flutter_application/models/sensor.dart';
import 'package:flutter_application/services/fake_sensor_service.dart';
import 'package:flutter_application/services/sensor_service.dart';
import 'package:intl/intl.dart';

class SensorScreen extends StatefulWidget {
  final double? lat;
  final double? lon;
  const SensorScreen({Key? key, this.lat, this.lon}) : super(key: key);

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final AbstractSensorService _fakeSensorService = FakeSensorService();
  List<Sensor> _readings = [];
  DateTime _selectedDate = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReadings();
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
    final readings = await _fakeSensorService.getSensorsByDate(
      startDate: startOfDay,
      endDate: endOfDay,
    );
    setState(() {
      _readings =
          readings.where((r) {
            if (widget.lat != null && widget.lon != null) {
              return (r.latitude == widget.lat && r.longitude == widget.lon);
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
        title: const Text('Sensor Data'),
        actions: [
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
                          child: ListTile(
                            title: Text(
                              'Temp: ${r.temperature.toStringAsFixed(1)}°C, Humidity: ${r.humidity.toStringAsFixed(1)}%, Moisture: ${r.moisture.toStringAsFixed(1)}%',
                            ),
                            subtitle: Text(
                              DateFormat(
                                'yyyy-MM-dd HH:mm:ss',
                              ).format(r.timestamp),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
