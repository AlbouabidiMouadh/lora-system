import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/notification_model.dart';
import 'package:flutter_application/models/reason.dart';
import 'package:flutter_application/models/type.dart';
import 'package:flutter_application/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AbstractNotificationService notificationService = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    notificationService.markAllAsSeen();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = notificationService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3FA34D), Color(0xFF4C5D4D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
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
                color:
                    notif.isRead ? Colors.grey.shade100 : Colors.blue.shade50,
                elevation: notif.isRead ? 1 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    _getNotificationIcon(notif.type, notif.reason),
                    color: _getNotificationColor(notif.type, notif.reason),
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
                      notif.isRead
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

  IconData _getNotificationIcon(NotifType type, Reason reason) {
    switch (type) {
      case NotifType.alert:
        switch (reason) {
          case Reason.temp:
            return Icons.thermostat;
          case Reason.water:
            return Icons.water_drop;
          case Reason.pump:
            return Icons.warning;
        }
      case NotifType.reminder:
        return Icons.notifications_active;
      case NotifType.promotion:
        return Icons.local_offer;
      case NotifType.info:
        switch (reason) {
          case Reason.temp:
            return Icons.thermostat;
          case Reason.water:
            return Icons.water_drop;
          case Reason.pump:
            return Icons.info_outline;
        }
    }
  }

  Color _getNotificationColor(NotifType type, Reason reason) {
    switch (type) {
      case NotifType.alert:
        switch (reason) {
          case Reason.temp:
            return Colors.red;
          case Reason.water:
            return Colors.blue;
          case Reason.pump:
            return Colors.orange;
        }
      case NotifType.reminder:
        return Colors.purple;
      case NotifType.promotion:
        return Colors.green;
      case NotifType.info:
        return Colors.grey;
    }
  }
}
