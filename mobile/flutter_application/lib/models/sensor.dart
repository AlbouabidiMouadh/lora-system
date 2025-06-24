import 'package:flutter/foundation.dart';

class Sensor {
  final double temperature;
  final double humidity;
  final double waterCapacity;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final String? userId;
  final String? pumpId;

  Sensor({
    required this.temperature,
    required this.humidity,
    required this.waterCapacity,
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.userId,
    this.pumpId,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    try {
      double parseToDouble(dynamic value, String fieldName) {
        if (value == null) {
          throw FormatException('Field "$fieldName" is missing');
        }
        if (value is num) return value.toDouble();
        if (value is String) {
          final result = double.tryParse(value);
          if (result != null) return result;
          throw FormatException(
            'Invalid number format for "$fieldName": "$value"',
          );
        }
        throw FormatException(
          'Unexpected type for "$fieldName": ${value.runtimeType}',
        );
      }

      DateTime? parseTimestamp(dynamic value) {
        if (value == null) {
          return null; // Default to now if null
        }
        if (value is String) {
          try {
            return DateTime.parse(value).toLocal();
          } catch (e) {
            return null;
          }
        }
        throw FormatException(
          'Unexpected type for "timestamp": ${value.runtimeType}',
        );
      }

      return Sensor(
        temperature: parseToDouble(json['temperature'] ?? 0.0, 'temperature'),
        humidity: parseToDouble(json['humidity'] ?? 0.0, 'humidity'),
        waterCapacity: parseToDouble(json['waterCapacity'], 'waterCapacity'),
        latitude: parseToDouble(json['latitude'], 'latitude'),
        longitude: parseToDouble(json['longitude'], 'longitude'),
        timestamp: parseTimestamp(json['timestamp']),
        userId: json['user'] as String?,
        pumpId: json['pump'] as String?,
      );
    } catch (e, stacktrace) {
      debugPrint(
        'Error parsing SensorReading JSON: $json \n Details: $e \n Stacktrace: $stacktrace',
      );
      throw FormatException('Failed to parse SensorReading data: $e');
    }
  }
}
