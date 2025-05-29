import 'package:flutter/foundation.dart';

class SensorReading {
  final double temperature;
  final double humidity;
  final double moisture;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  SensorReading({
    required this.temperature,
    required this.humidity,
    required this.moisture,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
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

      DateTime parseTimestamp(dynamic value) {
        if (value == null) {
          throw const FormatException('Field "timestamp" is missing');
        }
        if (value is String) {
          try {
            return DateTime.parse(value).toLocal();
          } catch (e) {
            throw FormatException('Invalid timestamp format: "$value" - $e');
          }
        }
        throw FormatException(
          'Unexpected type for "timestamp": ${value.runtimeType}',
        );
      }

      return SensorReading(
        temperature: parseToDouble(json['temperature'], 'temperature'),
        humidity: parseToDouble(json['humidity'], 'humidity'),
        moisture: parseToDouble(json['moisture'], 'moisture'),
        latitude: parseToDouble(json['latitude'], 'latitude'),
        longitude: parseToDouble(json['longitude'], 'longitude'),
        timestamp: parseTimestamp(json['timestamp']),
      );
    } catch (e, stacktrace) {
      debugPrint(
        'Error parsing SensorReading JSON: $json \n Details: $e \n Stacktrace: $stacktrace',
      );
      throw FormatException('Failed to parse SensorReading data: $e');
    }
  }
}
