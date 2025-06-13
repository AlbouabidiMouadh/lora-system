import 'package:flutter_application/models/reason.dart';
import 'package:flutter_application/models/type.dart';

class NotificationModel {
  final String title;
  final String message;
  final DateTime createdAt;
  NotifType type;
  Reason reason;
  // Default type, can be changed if needed
  bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type = NotifType.info,
    this.reason = Reason.water,
    // Default type is info
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      type: TypeExtension.fromString(json["type"]),
      reason: ReasonExtension.fromString(json["reason"]),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'created_at': createdAt.toIso8601String(),
    "type": type.name,
    "reason": reason.name,
    'isRead': isRead,
  };
}
