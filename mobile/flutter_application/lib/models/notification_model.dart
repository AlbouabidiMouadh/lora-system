class NotificationModel {
  final String title;
  final String message;
  final DateTime createdAt;
  bool seen;

  NotificationModel({
    required this.title,
    required this.message,
    required this.createdAt,
    this.seen = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      seen: json['seen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'created_at': createdAt.toIso8601String(),
    'seen': seen,
  };
}
