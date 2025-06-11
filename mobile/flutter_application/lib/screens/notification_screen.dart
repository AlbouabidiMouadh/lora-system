import 'package:flutter/material.dart';
import 'package:flutter_application/models/notification_model.dart';
import 'package:flutter_application/services/fake_notification_service.dart';
import 'package:flutter_application/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AbstractNotificationService notificationService = FakeNotificationService();

  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = notificationService.getNotifications();
    notificationService.markAllAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }
          final notifications = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                color: notif.seen ? Colors.grey.shade100 : Colors.blue.shade50,
                elevation: notif.seen ? 1 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    notif.title.toLowerCase().contains('temp')
                        ? Icons.thermostat
                        : notif.title.toLowerCase().contains('water')
                        ? Icons.water_drop
                        : Icons.warning,
                    color:
                        notif.title.toLowerCase().contains('temp')
                            ? Colors.red
                            : notif.title.toLowerCase().contains('water')
                            ? Colors.blue
                            : Colors.orange,
                  ),
                  title: Text(
                    notif.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif.message),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(notif.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      notif.seen
                          ? const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 20,
                          )
                          : const Icon(
                            Icons.fiber_new,
                            color: Colors.blue,
                            size: 20,
                          ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
