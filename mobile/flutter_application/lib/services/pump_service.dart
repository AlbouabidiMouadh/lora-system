import 'package:flutter_application/models/pump.dart';
import 'package:flutter_application/models/pump_status.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter/foundation.dart';

abstract class AbstractPumpService {
  Future<List<Pump>> getAllPumps();

  Future<bool> updatePumpStatus({
    required String id,
    required PumpStatus status,
  });

  Future<Pump?> getPumpById(String id);
}

class PumpService implements AbstractPumpService {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Pump>> getAllPumps() async {
    try {
      final response = await _apiService.get('pumps/');
      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        final pumps =
            (response['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map((item) => Pump.fromJson(item))
                .toList();
        return pumps;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('[PumpService] Exception fetching all pumps: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updatePumpStatus({
    required String id,
    required PumpStatus status,
  }) async {
    try {
      final response = await _apiService.patch(
        'pumps/$id/status',
        status.toJson(),
      );
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

  @override
  Future<Pump?> getPumpById(String id) async {
    try {
      final response = await _apiService.get('pumps/$id');
      if (response is Map &&
          response['success'] == true &&
          response['data'] != null) {
        return Pump.fromJson(response['data']);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('[PumpService] Exception fetching pump by id: $e');
      return null;
    }
  }
}
