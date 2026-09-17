import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/app/models/task_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Preference Keys
  static const String keyNotificationsEnabled = 'is_notifications_enabled';
  static const String keyReminderMinutes = 'notification_reminder_minutes';
  static const String keySoundEnabled = 'is_notification_sound_enabled';
  static const String keyVibrationEnabled = 'is_notification_vibration_enabled';

  // Local settings cache
  bool isNotificationsEnabled = true;
  int reminderMinutes = 5; // Default: 5 minutes before due time
  bool isSoundEnabled = true;
  bool isVibrationEnabled = true;

  Future<void> init() async {
    if (_isInitialized) return;

    await _loadPreferences();

    try {
      // 1. Initialize Timezone safely
      tz.initializeTimeZones();
      String timeZoneName = 'Asia/Kolkata';
      try {
        timeZoneName = await FlutterTimezone.getLocalTimezone();
        if (timeZoneName == 'Asia/Calcutta' || timeZoneName == 'IST' || timeZoneName.contains('Calcutta')) {
          timeZoneName = 'Asia/Kolkata';
        }
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('[NotificationService] TimeZone location set to: $timeZoneName');
      } catch (e) {
        debugPrint('[NotificationService] Warning: Location $timeZoneName not found in tz DB: $e');
        final offset = DateTime.now().timeZoneOffset;
        if (offset.inMinutes == 330) {
          tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        } else {
          final locations = tz.timeZoneDatabase.locations;
          tz.Location? matchedLoc;
          for (var loc in locations.values) {
            if (loc.currentTimeZone.offset == offset.inMilliseconds) {
              matchedLoc = loc;
              break;
            }
          }
          tz.setLocalLocation(matchedLoc ?? tz.getLocation('Asia/Kolkata'));
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Error setting local timezone: $e');
    }

    // 2. Android & iOS Notification Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification_small');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // 3. Create High Importance Android Notification Channel & Request Permissions
    await _setupAndroidChannelAndPermissions();

    _isInitialized = true;
  }

  /// Load persisted notification settings from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isNotificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;
      reminderMinutes = prefs.getInt(keyReminderMinutes) ?? 5;
      isSoundEnabled = prefs.getBool(keySoundEnabled) ?? true;
      isVibrationEnabled = prefs.getBool(keyVibrationEnabled) ?? true;
    } catch (e) {
      log('Error loading notification preferences: $e');
    }
  }

  /// Save Notification Master Switch setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    isNotificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotificationsEnabled, enabled);
    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  /// Save Reminder Minutes setting
  Future<void> setReminderMinutes(int minutes) async {
    reminderMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyReminderMinutes, minutes);
  }

  /// Save Sound Toggle setting
  Future<void> setSoundEnabled(bool enabled) async {
    isSoundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySoundEnabled, enabled);
  }

  /// Save Vibration Toggle setting
  Future<void> setVibrationEnabled(bool enabled) async {
    isVibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyVibrationEnabled, enabled);
  }

  Future<void> _setupAndroidChannelAndPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      final vibePattern = Int64List.fromList([0, 500, 1000, 500]);
      final noVibePattern = Int64List.fromList([0]);

      final AndroidNotificationChannel soundVibeChannel =
          AndroidNotificationChannel(
            'task_reminder_channel_sound_vibe',
            'Task Reminders (Sound & Vibration)',
            description: 'Notifications with sound and vibration alerts',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            vibrationPattern: vibePattern,
          );

      final AndroidNotificationChannel soundChannel =
          AndroidNotificationChannel(
            'task_reminder_channel_sound',
            'Task Reminders (Sound Only)',
            description: 'Notifications with sound alerts only',
            importance: Importance.max,
            playSound: true,
            enableVibration: false,
            vibrationPattern: noVibePattern,
          );

      final AndroidNotificationChannel vibeChannel = AndroidNotificationChannel(
        'task_reminder_channel_vibe',
        'Task Reminders (Vibration Only)',
        description: 'Notifications with vibration alerts only',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
        vibrationPattern: vibePattern,
      );

      final AndroidNotificationChannel silentChannel =
          AndroidNotificationChannel(
            'task_reminder_channel_silent',
            'Task Reminders (Silent)',
            description:
                'Silent notifications without sound or vibration alerts',
            importance: Importance.defaultImportance,
            playSound: false,
            enableVibration: false,
            vibrationPattern: noVibePattern,
          );

      await androidImplementation.createNotificationChannel(soundVibeChannel);
      await androidImplementation.createNotificationChannel(soundChannel);
      await androidImplementation.createNotificationChannel(vibeChannel);
      await androidImplementation.createNotificationChannel(silentChannel);
    }
  }

  /// Request Notification and Exact Alarm permissions explicitly after UI is attached
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        final bool? notifGranted = await androidImplementation
            .requestNotificationsPermission();
        debugPrint('[NotificationService] Notification permission request granted: $notifGranted');
        await androidImplementation.requestExactAlarmsPermission();
        return notifGranted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Error requesting notification permissions: $e');
    }
    return false;
  }

  NotificationDetails _notificationDetails() {
    final String channelId = isSoundEnabled
        ? (isVibrationEnabled
              ? 'task_reminder_channel_sound_vibe'
              : 'task_reminder_channel_sound')
        : (isVibrationEnabled
              ? 'task_reminder_channel_vibe'
              : 'task_reminder_channel_silent');

    final String channelName = isSoundEnabled
        ? (isVibrationEnabled
              ? 'Task Reminders (Sound & Vibration)'
              : 'Task Reminders (Sound Only)')
        : (isVibrationEnabled
              ? 'Task Reminders (Vibration Only)'
              : 'Task Reminders (Silent)');

    final vibePattern = isVibrationEnabled
        ? Int64List.fromList([0, 500, 1000, 500])
        : Int64List.fromList([0]);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription:
              'Notifications for upcoming task reminders and due times',
          importance: isSoundEnabled
              ? Importance.max
              : (isVibrationEnabled
                    ? Importance.high
                    : Importance.defaultImportance),
          priority: isSoundEnabled ? Priority.high : Priority.defaultPriority,
          playSound: isSoundEnabled,
          enableVibration: isVibrationEnabled,
          vibrationPattern: vibePattern,
          icon: '@drawable/ic_notification_small',
          largeIcon: const DrawableResourceAndroidBitmap(
            '@drawable/ic_notification_large',
          ),
          color: const Color(0xFF4F46E5),
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: isSoundEnabled,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Helper to convert DateTime safely to TZDateTime in local time
  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    final localDt = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    try {
      return tz.TZDateTime(
        tz.local,
        localDt.year,
        localDt.month,
        localDt.day,
        localDt.hour,
        localDt.minute,
        localDt.second,
      );
    } catch (e) {
      return tz.TZDateTime.from(localDt, tz.local);
    }
  }

  /// Safe Zoned Schedule with fallback if exact alarm permission is restricted
  Future<void> _scheduleNotificationHelper({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    if (!isNotificationsEnabled) return;

    final nowTz = tz.TZDateTime.now(tz.local);

    // Do not trigger or schedule notification if due date/time is in the past
    if (!scheduledDate.isAfter(nowTz)) {
      debugPrint(
        '[NotificationService] Skipping notification for past date task [$id] at $scheduledDate (now: $nowTz)',
      );
      return;
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[NotificationService] Scheduled Exact Notification [$id] at $scheduledDate');
    } catch (e) {
      debugPrint('[NotificationService] Exact alarm scheduling error ($e). Retrying with inexact mode...');
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('[NotificationService] Scheduled Inexact Notification [$id] at $scheduledDate');
      } catch (err) {
        debugPrint('[NotificationService] Error scheduling notification: $err');
      }
    }
  }

  /// 1. Instant Notification when a new Task is created
  Future<void> showInstantTaskCreatedNotification(TaskModel task) async {
    if (!isNotificationsEnabled) return;

    try {
      final int notificationId = (task.id.hashCode + 99) & 0x7FFFFFFF;
      final formattedTime = DateFormat('MMM dd, h:mm a').format(task.dueDate);

      await _notificationsPlugin.show(
        notificationId,
        'Task Created Successfully!',
        '"${task.title}" has been set for $formattedTime',
        _notificationDetails(),
      );
    } catch (e) {
      log('Error showing instant notification: $e');
    }
  }

  /// 2. Schedule Task Notifications (Configurable reminder & exact due time)
  Future<void> scheduleTaskNotifications(TaskModel task) async {
    if (!isNotificationsEnabled || task.isCompleted) return;

    try {
      final now = DateTime.now();

      final int idReminder = (task.id.hashCode & 0x7FFFFFFF);
      final int idExact = ((task.id.hashCode + 1) & 0x7FFFFFFF);

      await cancelTaskNotifications(task.id);

      final formattedTime = DateFormat('h:mm a').format(task.dueDate);

      // A) Configurable Reminder (e.g. 5, 15, 30, 60 minutes before)
      if (reminderMinutes > 0) {
        final reminderTime = task.dueDate.subtract(
          Duration(minutes: reminderMinutes),
        );
        if (reminderTime.isAfter(now)) {
          final reminderLabel = reminderMinutes >= 60
              ? '${reminderMinutes ~/ 60} Hour'
              : '$reminderMinutes-Minute';

          await _scheduleNotificationHelper(
            id: idReminder,
            title: '$reminderLabel Task Reminder!',
            body:
                '"${task.title}" is due in $reminderMinutes minutes ($formattedTime)',
            scheduledDate: _toTZDateTime(reminderTime),
          );
        }
      }

      // B) Exact Due Time Notification
      if (task.dueDate.add(const Duration(minutes: 1)).isAfter(now)) {
        await _scheduleNotificationHelper(
          id: idExact,
          title: 'Task Due Now!',
          body: '"${task.title}" is due right now ($formattedTime)',
          scheduledDate: _toTZDateTime(task.dueDate),
        );
      }
    } catch (e) {
      log('Error scheduling task notifications: $e');
    }
  }

  /// Send an instant test notification
  Future<void> sendTestNotification() async {
    try {
      await requestPermissions();

      if (isVibrationEnabled) {
        HapticFeedback.heavyImpact();
      }

      await _notificationsPlugin.show(
        999999,
        'Test Notification',
        'Your notification settings are working perfectly!',
        _notificationDetails(),
      );
      debugPrint('[NotificationService] Test notification show call completed!');
    } catch (e) {
      debugPrint('[NotificationService] Error sending test notification: $e');
    }
  }

  /// Cancel Notifications for a specific Task
  Future<void> cancelTaskNotifications(String taskId) async {
    try {
      final int idReminder = (taskId.hashCode & 0x7FFFFFFF);
      final int idExact = ((taskId.hashCode + 1) & 0x7FFFFFFF);

      await _notificationsPlugin.cancel(idReminder);
      await _notificationsPlugin.cancel(idExact);
    } catch (e) {
      log('Error cancelling notifications: $e');
    }
  }

  /// Cancel ALL scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      log('Cancelled all active notifications.');
    } catch (e) {
      log('Error cancelling all notifications: $e');
    }
  }
}
