import 'package:flutter/material.dart';
import 'package:flutter_application/models/sensor.dart';
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
  final SensorService _fakeSensorService = SensorService();
  List<Sensor> _readings = [];
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() => _loading = true);
    final readings = await _fakeSensorService.getSensorsByDate(
      startDate: _fromDate,
      endDate: _toDate,
    );
    setState(() {
     /*  _readings =
          readings.where((r) {
            if (widget.lat != null && widget.lon != null) {
              return (r.latitude == widget.lat && r.longitude == widget.lon);
            }
            return true;
          }).toList(); */
      _loading = false;
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange:
          _fromDate != null && _toDate != null
              ? DateTimeRange(start: _fromDate!, end: _toDate!)
              : null,
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
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
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body:
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
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(r.timestamp),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
