import 'package:flutter_application/services/api_service.dart';
import 'package:flutter/foundation.dart';

class PumpService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getPumpStatus() async {
    try {
      final response = await _apiService.get('api/pump/1/');
      return response;
    } catch (e) {
      debugPrint('[PumpService] Exception fetching pump status: $e');
      throw Exception('Error fetching pump status: $e');
    }
  }

  Future<bool> setPumpState(bool isOn) async {
    try {
      final response = await _apiService.put('api/pump/1/', {'is_on': isOn});
      return response['success'] == true;
    } catch (e) {
      debugPrint('[PumpService] Exception setting pump state: $e');
      throw Exception('Error setting pump state: $e');
    }
  }
}
