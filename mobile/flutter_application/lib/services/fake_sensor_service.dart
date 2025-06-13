import 'package:flutter_application/models/sensor.dart';
import 'package:flutter_application/services/sensor_service.dart';

class FakeSensorService implements AbstractSensorService {
  // Mock sensors with close lat/long
  final List<Sensor> _mockSensors = [
    Sensor(
      temperature: 23.5,
      humidity: 55.0,
      waterCapacity: 30.0,
      latitude: 37.4219983,
      longitude: -122.084,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      userId: 'user1',
      pumpId: 'p1',
    ),
    Sensor(
      temperature: 24.1,
      humidity: 56.0,
      waterCapacity: 32.0,
      latitude: 37.422,
      longitude: -122.0841,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      userId: 'user1',
      pumpId: 'p2',
    ),
    Sensor(
      temperature: 22.8,
      humidity: 60.0,
      waterCapacity: 28.0,
      latitude: 37.4221,
      longitude: -122.0842,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      userId: 'user2',
      pumpId: 'p3',
    ),
  ];

  @override
  Future<List<Sensor>> getAllSensors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Sensor>.from(_mockSensors);
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
        .where(
          (sensor) =>
              sensor.timestamp!.isAfter(start) && sensor.timestamp!.isBefore(end)  ,
        )
        .toList();
  }
}
