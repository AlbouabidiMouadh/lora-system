import 'package:flutter/foundation.dart';
import 'package:flutter_application/models/notification_model.dart';
import 'package:flutter_application/services/api_service.dart';

abstract class AbstractNotificationService {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAllAsSeen();
}

class NotificationService implements AbstractNotificationService {
  final ApiService _apiService = ApiService();

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get('notifications');
      if (response is Map &&
          response['success'] == true &&
          response['data'] is List) {
        final notifications =
            (response['data'] as List)
                .whereType<Map<String, dynamic>>()
                .map((item) => NotificationModel.fromJson(item))
                .toList();
        return notifications;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('[NotificationService] Exception fetching notifications: $e');
      return [];
    }
  }

  @override
  Future<void> markAllAsSeen() async {
    try {
      await _apiService.patch('notifications/read-all', {});
    } catch (e) {
      debugPrint(
        '[NotificationService] Exception marking notifications as seen: $e',
      );
    }
  }
}
