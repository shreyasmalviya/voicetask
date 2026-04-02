import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'voicetask_channel';
  static const String _channelName = 'VoiceTask Notifications';
  static const String _channelDescription = 'Task reminders and daily summaries';

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — navigation is handled by the app
  }

  /// Schedule daily summary notification
  Future<void> scheduleDailySummary(int hour, int minute) async {
    // Cancel existing daily summary
    await _plugin.cancel(0);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      '📋 Daily Task Summary',
      'Check your task progress for today!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule a reminder 30 minutes before task due time
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.dueDate == null) return;

    final reminderTime =
        task.dueDate!.subtract(const Duration(minutes: 30));
    if (reminderTime.isBefore(DateTime.now())) return;

    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    // Use task hashCode for unique notification ID
    final notificationId = task.id.hashCode;

    await _plugin.zonedSchedule(
      notificationId,
      '⏰ Task Reminder',
      '${task.title} is due in 30 minutes',
      tzReminderTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a task's reminder
  Future<void> cancelTaskReminder(String taskId) async {
    await _plugin.cancel(taskId.hashCode);
  }

  /// Show archive notification
  Future<void> showArchiveNotification(int count) async {
    if (count == 0) return;

    await _plugin.show(
      999,
      '🎉 Tasks Archived',
      '$count completed task${count > 1 ? 's' : ''} archived for the day. Great work!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Show a quick notification
  Future<void> showNotification(String title, String body) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
