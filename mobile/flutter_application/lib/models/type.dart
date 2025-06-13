enum NotifType { info,alert,reminder,promotion}

extension TypeExtension on NotifType {
  String get name {
    switch (this) {
      case NotifType.info:
        return 'Info';
      case NotifType.alert:
        return 'Alert';
      case NotifType.reminder:
        return 'Reminder';
      case NotifType.promotion:
        return 'Promotion';
    }
  }

  


  static NotifType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'info':
        return NotifType.info;
      case 'alert':
        return NotifType.alert;
      case 'reminder':
        return NotifType.reminder;
      case 'promotion':
        return NotifType.promotion;
      default:
        return NotifType.info; // Default case if no match found
    }
  }

  Map<String, dynamic> toJson() {
    return {'type': name};
  }
}