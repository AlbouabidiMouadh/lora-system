import 'package:flutter_application/services/api_service.dart';
import 'package:flutter/foundation.dart';

class TankService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getLatestTankLevel() async {
    try {
      final response = await _apiService.get('api/tank/latest/');
      return response;
    } catch (e) {
      debugPrint('[TankService] Exception fetching tank level: $e');
      throw Exception('Error fetching tank level: $e');
    }
  }
}
