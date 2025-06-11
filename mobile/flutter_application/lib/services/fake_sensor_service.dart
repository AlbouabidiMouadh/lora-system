
import 'package:flutter_application/models/sensor.dart';
import 'package:flutter_application/services/sensor_service.dart';


class FakeSensorService implements AbstractSensorService {
  // Mock sensors with close lat/long
  final List<Map<String, dynamic>> _mockSensors = [
    {
      'id': '1',
      'name': 'Soil Sensor 1',
      'latitude': 37.4219983,
      'longitude': -122.084,
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'value': 23.5,
    },
    {
      'id': '2',
      'name': 'Soil Sensor 2',
      'latitude': 37.422,
      'longitude': -122.0841,
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'value': 24.1,
    },
    {
      'id': '3',
      'name': 'Soil Sensor 3',
      'latitude': 37.4221,
      'longitude': -122.0842,
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'value': 22.8,
    },
  ];



  @override
  Future<List<Sensor>> getAllSensors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSensors.map((e) => Sensor.fromJson(e)).toList();
  }

  @override
  Future<List<Sensor>> getSensorsByDate({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 1));
    final end = endDate ?? now;
    return _mockSensors
        .map((e) => Sensor.fromJson(e))
        .where(
          (sensor) =>
              sensor.timestamp.isAfter(start) && sensor.timestamp.isBefore(end),
        )
        .toList();
  }
}
