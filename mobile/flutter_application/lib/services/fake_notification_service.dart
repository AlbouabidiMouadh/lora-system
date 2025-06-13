import 'package:flutter_application/models/notification_model.dart';
import 'package:flutter_application/services/notification_service.dart';

class FakeNotificationService implements AbstractNotificationService {
  final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      title: 'High Temperature',
      message: 'Temperature exceeded safe level!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isRead: false,
    ),
    NotificationModel(
      title: 'Low Water Level',
      message: 'Water level is below minimum threshold.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationModel(
      title: 'Pump Problem',
      message: 'Pump stopped unexpectedly.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
  ];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockNotifications;
  }

  @override
  Future<void> markAllAsSeen() async {
    for (var notif in _mockNotifications) {
      notif.isRead = true;
    }
  }
}
