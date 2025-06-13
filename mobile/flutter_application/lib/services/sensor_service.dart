import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_application/models/sensor.dart';
import 'package:flutter/foundation.dart';

abstract class AbstractSensorService {
  Future<List<Sensor>> getAllSensors();
  Future<List<Sensor>> getSensorsByDate({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class SensorService implements AbstractSensorService {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Sensor>> getAllSensors() async {
    try {
      final response = await _apiService.get('sensors');
      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        final sensors =
            (response['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map((item) => Sensor.fromJson(item))
                .toList();
        return sensors;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('[SensorService] Exception fetching sensors: $e');
      return [];
    }
  }

  @override
  Future<List<Sensor>> getSensorsByDate({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiService.get('sensors');
      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        final sensors =
            (response['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map((item) => Sensor.fromJson(item))
                .where(
                  (sensor) =>
                      (sensor.timestamp?.isAfter(startDate ?? DateTime.now()) ??
                          false) &&
                      (sensor.timestamp?.isBefore(endDate ?? DateTime.now()) ??
                          false),
                )
                .toList();
        return sensors;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('[SensorService] Exception fetching sensors by date: $e');
      return [];
    }
  }
}
