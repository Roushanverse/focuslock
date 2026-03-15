import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for showing notifications (taunts, reminders, etc.).
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _tauntChannelId = 'focuslock_taunts';
  static const String _tauntChannelName = 'Focus Taunts';
  static const String _tauntChannelDesc =
      'Notifications when you try to open blocked apps';

  /// Initialize the notification plugin.
  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Create notification channel for Android 8+
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _tauntChannelId,
          _tauntChannelName,
          description: _tauntChannelDesc,
          importance: Importance.high,
        ),
      );
    }
  }

  /// Show a taunt notification with a meme caption.
  Future<void> showTauntNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _tauntChannelId,
      _tauntChannelName,
      channelDescription: _tauntChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  /// Show a general notification.
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'focuslock_general',
      'FocusLock',
      channelDescription: 'General notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  /// Cancel a notification by ID.
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
