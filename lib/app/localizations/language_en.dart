import 'package:task_manager/app/localizations/language.dart';

class LanguageEn extends Languages {
  // App & Common
  @override
  String get appTitle => "Task Manager";
  @override
  String get save => "Save";
  @override
  String get cancel => "Cancel";
  @override
  String get ok => "OK";
  @override
  String get delete => "Delete";
  @override
  String get edit => "Edit";
  @override
  String get confirm => "Confirm";

  // Profile Screen
  @override
  String get profile => "Profile";
  @override
  String get totalTasks => "Total Tasks";
  @override
  String get completed => "Completed";
  @override
  String get pending => "Pending";
  @override
  String get appTheme => "App Theme";
  @override
  String get chooseThemeAppearance => "Choose your preferred appearance mode";
  @override
  String get lightMode => "Light Mode";
  @override
  String get lightModeSubtitle => "Always use clean light theme";
  @override
  String get darkMode => "Dark Mode";
  @override
  String get darkModeSubtitle => "Always use sleek dark theme";
  @override
  String get systemDefault => "System Default";
  @override
  String get systemDefaultSubtitle => "Match system device settings automatically";
  @override
  String get language => "Language";
  @override
  String get appLanguage => "App Language";
  @override
  String get choosePreferredLanguage => "Choose your preferred language";
  @override
  String get accountSettings => "Account Settings";
  @override
  String get notifications => "Notifications";
  @override
  String get notificationSettings => "Notification Settings";
  @override
  String get pushNotifications => "Push Notifications";
  @override
  String get notificationsEnabledSubtitle => "Notifications are enabled";
  @override
  String get notificationsDisabledSubtitle => "All task alerts are disabled";
  @override
  String get defaultReminderTiming => "Default Reminder Timing";
  @override
  String get atDueTime => "At Due Time";
  @override
  String get fiveMinsBefore => "5 Mins Before";
  @override
  String get fifteenMinsBefore => "15 Mins Before";
  @override
  String get alertStyle => "Alert Style";
  @override
  String get soundAlert => "Sound Alert";
  @override
  String get vibrationAlert => "Vibration Alert";
  @override
  String get sendTestNotification => "Send Test Notification";
  @override
  String get testNotificationSent => "Test notification sent! Check your notification tray.";
  @override
  String get aboutUs => "About Us";
  @override
  String get privacyPolicy => "Privacy & Policy";
  @override
  String get logout => "Logout";
  @override
  String get logoutConfirmation => "Are you sure you want to logout?";
  @override
  String get logoutMessage => "You will need to login again to access your tasks.";
  @override
  String get profilePictureUpdated => "Profile picture updated successfully!";

  // Home Screen
  @override
  String get hello => "Hello";
  @override
  String get pendingTasksMsg => "pending tasks";
  @override
  String get dailyCompletion => "Daily Completion";
  @override
  String get doneTasks => "Done";
  @override
  String get completedOfTotal => "completed of total tasks";
  @override
  String get searchHint => "Search tasks by title or note...";
  @override
  String get noTasksFound => "No tasks found";
  @override
  String get tapToCreateTask => "Tap \"+ Add Task\" button to create a new task.";
  @override
  String get completedTasksSection => "Completed";
  @override
  String get editTask => "Edit Task";
  @override
  String get deleteTask => "Delete Task";
  @override
  String get deleteTaskConfirmation => "Are you sure you want to delete this task?";

  // Add/Edit Task Bottom Sheet
  @override
  String get addNewTask => "Add New Task";
  @override
  String get taskTitleHint => "Task Title";
  @override
  String get taskDescriptionHint => "Description (Optional)";
  @override
  String get selectCategory => "Select Category";
  @override
  String get selectPriority => "Select Priority";
  @override
  String get dueDateTime => "Due Date & Time";
  @override
  String get selectDate => "Select Date";
  @override
  String get selectTime => "Select Time";
  @override
  String get createTask => "Create Task";
  @override
  String get updateTask => "Update Task";

  // Categories (Firebase & UI)
  @override
  String get all => "All";
  @override
  String get work => "Work";
  @override
  String get personal => "Personal";
  @override
  String get shopping => "Shopping";
  @override
  String get fitness => "Fitness";
  @override
  String get other => "Other";

  // Priority (Firebase & UI)
  @override
  String get high => "High";
  @override
  String get medium => "Medium";
  @override
  String get low => "Low";

  // Status (Firebase & UI)
  @override
  String get statusPending => "Pending";
  @override
  String get statusCompleted => "Completed";

  // Bottom Navigation
  @override
  String get home => "Home";
}
