import 'package:flutter/material.dart';

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  // App & Common
  String get appTitle;
  String get save;
  String get cancel;
  String get ok;
  String get delete;
  String get edit;
  String get confirm;

  // Profile Screen
  String get profile;
  String get totalTasks;
  String get completed;
  String get pending;
  String get appTheme;
  String get chooseThemeAppearance;
  String get lightMode;
  String get lightModeSubtitle;
  String get darkMode;
  String get darkModeSubtitle;
  String get systemDefault;
  String get systemDefaultSubtitle;
  String get language;
  String get appLanguage;
  String get choosePreferredLanguage;
  String get accountSettings;
  String get notifications;
  String get notificationSettings;
  String get pushNotifications;
  String get notificationsEnabledSubtitle;
  String get notificationsDisabledSubtitle;
  String get defaultReminderTiming;
  String get atDueTime;
  String get fiveMinsBefore;
  String get fifteenMinsBefore;
  String get alertStyle;
  String get soundAlert;
  String get vibrationAlert;
  String get sendTestNotification;
  String get testNotificationSent;
  String get aboutUs;
  String get privacyPolicy;
  String get logout;
  String get logoutConfirmation;
  String get logoutMessage;
  String get profilePictureUpdated;

  // Home Screen
  String get hello;
  String get pendingTasksMsg;
  String get dailyCompletion;
  String get doneTasks;
  String get completedOfTotal;
  String get searchHint;
  String get noTasksFound;
  String get tapToCreateTask;
  String get completedTasksSection;
  String get editTask;
  String get deleteTask;
  String get deleteTaskConfirmation;

  // Add/Edit Task Bottom Sheet
  String get addNewTask;
  String get taskTitleHint;
  String get taskDescriptionHint;
  String get selectCategory;
  String get selectPriority;
  String get dueDateTime;
  String get selectDate;
  String get selectTime;
  String get createTask;
  String get updateTask;

  // Categories (Firebase & UI)
  String get all;
  String get work;
  String get personal;
  String get shopping;
  String get fitness;
  String get other;

  // Priority (Firebase & UI)
  String get high;
  String get medium;
  String get low;

  // Status (Firebase & UI)
  String get statusPending;
  String get statusCompleted;

  // Bottom Navigation
  String get home;

  /// Helper to dynamically translate Firestore Category strings
  String getCategoryName(String cat) {
    switch (cat.trim().toLowerCase()) {
      case 'all':
        return all;
      case 'work':
        return work;
      case 'personal':
        return personal;
      case 'shopping':
        return shopping;
      case 'fitness':
        return fitness;
      case 'other':
      case 'others':
        return other;
      default:
        return cat;
    }
  }

  /// Helper to dynamically translate Firestore Priority strings
  String getPriorityName(String prio) {
    switch (prio.trim().toLowerCase()) {
      case 'high':
        return high;
      case 'medium':
        return medium;
      case 'low':
        return low;
      default:
        return prio;
    }
  }
}