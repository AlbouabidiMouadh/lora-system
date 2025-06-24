import 'package:flutter_application/models/pump.dart';
import 'package:flutter_application/models/pump_status.dart';
import 'package:flutter_application/services/pump_service.dart';

class FakePumpService implements AbstractPumpService {
  // Mock pumps with close lat/long and related sensors
  final List<Map<String, dynamic>> _mockPumps = [
    {
      '_id': 'p1',
      'name': 'Main Pump',
      'status': 'on',
      'latitude': 37.4219983,
      'longitude': -122.084,
      'description': 'Main irrigation pump',
      'user_id': 'user1',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'sensors': [
        {
          'temperature': 28.5,
          'humidity': 60.0,
          'moisture': 30.0,
          'latitude': 37.4219983,
          'longitude': -122.084,
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(minutes: 10))
                  .toIso8601String(),
        },
        {
          'temperature': 27.0,
          'humidity': 62.0,
          'moisture': 32.0,
          'latitude': 37.4219983,
          'longitude': -122.084,
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
        },
      ],
    },
    {
      '_id': 'p2',
      'name': 'Backup Pump',
      'status': 'off',
      'latitude': 37.422,
      'longitude': -122.0841,
      'description': 'Backup pump',
      'user_id': 'user1',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'sensors': [
        {
          'temperature': 25.0,
          'humidity': 55.0,
          'moisture': 28.0,
          'latitude': 37.422,
          'longitude': -122.0841,
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(minutes: 20))
                  .toIso8601String(),
        },
      ],
    },
    {
      '_id': 'p3',
      'name': 'Greenhouse Pump',
      'status': 'maintenance',
      'latitude': 37.4221,
      'longitude': -122.0842,
      'description': 'Greenhouse water pump',
      'user_id': 'user2',
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'sensors': [
        {
          'temperature': 22.0,
          'humidity': 70.0,
          'moisture': 40.0,
          'latitude': 37.4221,
          'longitude': -122.0842,
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(minutes: 5))
                  .toIso8601String(),
        },
      ],
    },
  ];

  @override
  Future<List<Pump>> getAllPumps() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPumps.map((e) => Pump.fromJson(e)).toList();
  }

  @override
  Future<bool> updatePumpStatus({
    required String id,
    required PumpStatus status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockPumps.indexWhere((p) => p['_id'] == id);
    if (idx != -1) {
      _mockPumps[idx]['status'] = status.name;
      return true;
    }
    return false;
  }

  @override
  Future<Pump?> getPumpById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final pumpMap = _mockPumps.firstWhere(
      (p) => p['_id'] == id,
      orElse: () => <String, dynamic>{},
    );
    if (pumpMap.isNotEmpty) {
      return Pump.fromJson(pumpMap);
    }
    return null;
  }

  Future<List<Pump>> getPumps() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPumps.map((e) => Pump.fromJson(e)).toList();
  }
}
