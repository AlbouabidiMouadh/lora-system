import 'dart:convert';
import 'dart:math';
import 'package:flutter_application/models/pump.dart';
import 'package:flutter_application/models/pump_status.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/services/pump_service.dart';

class FakePumpService implements AbstractPumpService {
  final List<Pump> _pumps = [];
  static const String _cacheKey = 'fake_pumps';

  // Mock pumps with close lat/long
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
      'sensors': [],
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
      'sensors': [],
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
      'sensors': [],
    },
  ];

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _pumps.map((p) => p.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _pumps.clear();
      _pumps.addAll(jsonList.map((e) => Pump.fromJson(e)));
    }
  }

  Future<Pump> generateFakePump(Position position) async {
    await _loadFromCache();
    final random = Random();
    final pump = Pump(
      id: 'pump_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Pump ${random.nextInt(1000)}',
      status: PumpStatus.off,
      latitude: position.latitude,
      longitude: position.longitude,
      description: 'Fake pump generated at ${DateTime.now()}',
      userId: 'user1',
    );
    _pumps.add(pump);
    await _saveToCache();
    return pump;
  }

  Future<List<Pump>> getPumps() async {
    await _loadFromCache();
    return List<Pump>.from(_pumps);
  }

  Future<List<Pump>> getPumpsByStatus(PumpStatus status) async {
    await _loadFromCache();
    return _pumps.where((p) => p.status == status).toList();
  }

  Future<void> updatePump(Pump updatedPump) async {
    await _loadFromCache();
    final idx = _pumps.indexWhere((p) => p.id == updatedPump.id);
    if (idx != -1) {
      _pumps[idx] = updatedPump;
      await _saveToCache();
    }
  }

  Future<void> clear() async {
    _pumps.clear();
    await _saveToCache();
  }

  @override
  Future<Map<String, dynamic>> getAllPumps() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true, 'data': _mockPumps};
  }

  @override
  Future<Map<String, dynamic>> getPumpsByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final filtered =
        _mockPumps.where((p) {
          final dt = DateTime.tryParse(p['timestamp'] ?? '');
          return dt != null && dt.isAfter(startDate) && dt.isBefore(endDate);
        }).toList();
    return {'success': true, 'data': filtered};
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
}
