import 'package:flutter_application/models/pump_status.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter/foundation.dart';

class PumpService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getAllPumps() async {
    try {
      final response = await _apiService.get('api/pumps/');
      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        return {'success': true, 'data': response['data']};
      } else {
        return {'success': false, 'data': []};
      }
    } catch (e) {
      debugPrint('[PumpService] Exception fetching all pumps: $e');
      return {'success': false, 'data': []};
    }
  }

  Future<Map<String, dynamic>> getPumpsByDate({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiService.get('api/pumps/');
      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        final filtered =
            (response['data'] as List).where((p) {
              if (p is Map && p['timestamp'] != null) {
                final dt = DateTime.tryParse(p['timestamp']);
                if (dt != null) {
                  return dt.isAfter(startDate) && dt.isBefore(endDate);
                }
              }
              return false;
            }).toList();
        return {'success': true, 'data': filtered};
      } else {
        return {'success': false, 'data': []};
      }
    } catch (e) {
      debugPrint('[PumpService] Exception fetching pumps by date: $e');
      return {'success': false, 'data': []};
    }
  }

  Future<bool> updatePumpStatus({
    required String id,
    required PumpStatus status,
  }) async {
    try {
      final response = await _apiService.put('pumps/$id/status',status.toJson());
      if (response is Map && response['success'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('[PumpService] Exception updating pump status: $e');
      return false;
    }
  }
}
