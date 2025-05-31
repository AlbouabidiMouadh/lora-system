import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_application/Models/sensor_reading.dart';
import 'package:flutter/foundation.dart';

class SensorService {
  final ApiService _apiService = ApiService();

  Future<List<SensorReading>> fetchSensorReadings({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.get(
        'api/sensor-data?timestamp__gte=${startDate.toUtc().toIso8601String()}&timestamp__lt=${endDate.toUtc().toIso8601String()}',
      );
      if (response is List) {
        return response
            .whereType<Map<String, dynamic>>()
            .map((item) => SensorReading.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load sensor data.');
      }
    } catch (e) {
      debugPrint('[SensorService] Exception fetching sensor readings: $e');
      throw Exception('Failed to fetch sensor data. Details: $e');
    }
  }
}
