import 'dart:convert';
import 'dart:async';
import 'package:flutter_application_2/Models/sensor_reading.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  static const String _sensorDataEndpoint = '/api/sensor-data/';
  static const String _pumpEndpoint = '/api/pump/1/';

  static const String _tankLevelEndpoint = '/api/tank/latest/';

  Future<List<SensorReading>> fetchSensorReadings({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String startDateUtc = startDate.toUtc().toIso8601String();
      final String endDateUtc = endDate.toUtc().toIso8601String();

      final Uri uri = Uri.parse('$_baseUrl$_sensorDataEndpoint').replace(
        queryParameters: {
          'timestamp__gte': startDateUtc,
          'timestamp__lt': endDateUtc,
        },
      );

      debugPrint('[ApiService] Fetching sensor readings from: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        List<SensorReading> readings =
            body
                .whereType<Map<String, dynamic>>()
                .map((item) => SensorReading.fromJson(item))
                .toList();
        debugPrint('[ApiService] Fetched ${readings.length} sensor readings.');
        return readings;
      } else {
        debugPrint(
          '[ApiService] Sensor API Error - Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Failed to load sensor data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ApiService] Exception fetching sensor readings: $e');

      throw Exception('Failed to fetch sensor data. Details: $e');
    }
  }

  Future<Map<String, dynamic>> getPumpStatus() async {
    final Uri uri = Uri.parse('$_baseUrl$_pumpEndpoint');
    debugPrint('[ApiService] Fetching pump status from: $uri');

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('[ApiService] Pump status fetched successfully: $data');
        return data;
      } else {
        debugPrint(
          '[ApiService] Pump Status API Error - Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Failed to load pump status. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ApiService] Exception fetching pump status: $e');
      throw Exception('Error fetching pump status: $e');
    }
  }

  Future<bool> setPumpState(bool isOn) async {
    final Uri uri = Uri.parse('$_baseUrl$_pumpEndpoint');
    final body = jsonEncode({'is_on': isOn});
    debugPrint('[ApiService] Setting pump state to $isOn via PATCH to: $uri');

    try {
      final response = await http
          .patch(
            uri,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('[ApiService] Pump state successfully set to $isOn.');

        return true;
      } else {
        debugPrint(
          '[ApiService] Set Pump State API Error - Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception(
          'Failed to set pump state. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ApiService] Exception setting pump state: $e');
      throw Exception('Error setting pump state: $e');
    }
  }

  Future<Map<String, dynamic>> getLatestTankLevel() async {
    final Uri uri = Uri.parse('$_baseUrl$_tankLevelEndpoint');
    debugPrint('[ApiService] Fetching latest tank level from: $uri');
    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('[ApiService] Tank level fetched successfully: $data');
        return data;
      } else if (response.statusCode == 404) {
        debugPrint('[ApiService] No tank level data found (404)');
        return {
          'error': 'not_found',
          'message': 'No tank level data available yet.',
        };
      } else {
        debugPrint(
          '[ApiService] Tank Level API Error - Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to load tank level (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[ApiService] Exception fetching tank level: $e');
      throw Exception('Error fetching tank level: $e');
    }
  }
}
