import 'package:flutter/material.dart';

class NotificationService {
  static final List<Map<String, dynamic>> _notifications = [];

  static List<Map<String, dynamic>> get notifications => _notifications;

  static void addNotification({
    required String title,
    required String message,
    required String category,
    DateTime? timestamp,
  }) {
    _notifications.insert(0, {
      'title': title,
      'message': message,
      'category': category,
      'timestamp': timestamp ?? DateTime.now(),
    });
  }

  static void clearNotifications() {
    _notifications.clear();
  }
}