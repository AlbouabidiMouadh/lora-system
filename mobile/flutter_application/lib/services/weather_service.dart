import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter/widgets.dart';

class WeatherData {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final double? rain1h;
  final int dt;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    this.rain1h,
    required this.dt,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    T? parseNum<T extends num>(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is T) {
        return value;
      }
      if (value is String) {
        return num.tryParse(value) as T?;
      }

      if (value is int && T == double) {
        return value.toDouble() as T?;
      }
      if (value is double && T == int) {
        return value.round() as T?;
      }
      if (value is num) {
        return value as T?;
      }
      return null;
    }

    return WeatherData(
      cityName: json['name'] ?? 'Ville inconnue',

      temperature: parseNum<double>(json['main']?['temp']) ?? 0.0,
      description: json['weather']?[0]?['description'] ?? 'Pas de description',
      iconCode: json['weather']?[0]?['icon'] ?? '01d',

      humidity: parseNum<int>(json['main']?['humidity']) ?? 0,

      windSpeed: parseNum<double>(json['wind']?['speed']) ?? 0.0,

      rain1h: parseNum<double>(json['rain']?['1h']),

      dt:
          parseNum<int>(json['dt']) ??
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}

class WeatherService {
  final String? apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'];
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> getCurrentWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    if (apiKey == null) {
      throw Exception("Clé API non trouvée dans le fichier .env");
    }

    final url =
        '$baseUrl?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=fr';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Échec du chargement des données météo. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Échec de la connexion au service météo: $e');
    }
  }

  Future<WeatherData> getCurrentWeatherByCity(String city) async {
    if (apiKey == null) throw Exception("Clé API non trouvée");
    final url = '$baseUrl?q=$city&appid=$apiKey&units=metric&lang=fr';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Échec du chargement météo ville. Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Échec de la connexion au service météo: $e');
    }
  }

  IconData mapOwmCodeToIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return WeatherIcons.day_sunny;
      case '01n':
        return WeatherIcons.night_clear;
      case '02d':
        return WeatherIcons.day_cloudy;
      case '02n':
        return WeatherIcons.night_alt_cloudy;
      case '03d':
      case '03n':
        return WeatherIcons.cloud;
      case '04d':
      case '04n':
        return WeatherIcons.cloudy;
      case '09d':
      case '09n':
        return WeatherIcons.showers;
      case '10d':
        return WeatherIcons.day_rain;
      case '10n':
        return WeatherIcons.night_alt_rain;
      case '11d':
      case '11n':
        return WeatherIcons.thunderstorm;
      case '13d':
      case '13n':
        return WeatherIcons.snow;
      case '50d':
      case '50n':
        return WeatherIcons.fog;
      default:
        return WeatherIcons.na;
    }
  }
}
