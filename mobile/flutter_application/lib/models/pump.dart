import 'package:flutter_application/models/pump_status.dart';
import 'package:flutter_application/models/sensor.dart';

class Pump {
  final String id;
  final String name;
  final PumpStatus status;
  final double latitude;
  final double longitude;
  final String? description;
  final String userId;
   List<Sensor> sensors =  [];

  Pump({
    required this.id,
    required this.name,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.userId,
    this.sensors = const [],
  });

  factory Pump.fromJson(Map<String, dynamic> json) {
    return Pump(
      id: json['_id'] ?? "id1",
      name: json['name'] ,
      status: PumpStatusString.fromString( json['status']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] ,
      userId: json['user'] ,
      sensors: (json['sensors'] as List<dynamic>?)
              ?.map((sensorJson) => Sensor.fromJson(sensorJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'user_id': userId,
    };
  }
}
