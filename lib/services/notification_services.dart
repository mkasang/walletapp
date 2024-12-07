// lib/services/notification_service.dart

import 'package:walletapp/models/notifications.dart';
import 'package:walletapp/services/database_helper.dart';

class NotificationService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<WalletNotification> createNotification({
    required int userId,
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final notification = WalletNotification(
      id: 0,
      userId: userId,
      title: title,
      message: message,
      date: DateTime.now(),
      type: type,
      isRead: false,
    );

    return await _dbHelper.createNotification(notification);
  }

  Future<List<WalletNotification>> getUserNotifications(int userId) async {
    return await _dbHelper.getUserNotifications(userId);
  }

  Future<void> markAsRead(int notificationId) async {
    await _dbHelper.markNotificationAsRead(notificationId);
  }
}
