enum NotificationType {
  transaction,
  security,
  system,
}

class WalletNotification {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  WalletNotification({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'is_read': isRead ? 1 : 0,
    };
  }

  factory WalletNotification.fromMap(Map<String, dynamic> map) {
    return WalletNotification(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      message: map['message'],
      date: DateTime.parse(map['date']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      isRead: map['is_read'] == 1,
    );
  }
}
