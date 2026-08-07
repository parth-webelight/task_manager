import 'package:task_manager/app/localizations/language.dart';

class LanguageHi extends Languages {
  // App & Common
  @override
  String get appTitle => "टास्क मैनेजर";
  @override
  String get save => "सहेजें";
  @override
  String get cancel => "रद्द करें";
  @override
  String get ok => "ठीक है";
  @override
  String get delete => "हटाएं";
  @override
  String get edit => "संपादित करें";
  @override
  String get confirm => "पुष्टि करें";

  // Profile Screen
  @override
  String get profile => "प्रोफ़ाइल";
  @override
  String get totalTasks => "कुल कार्य";
  @override
  String get completed => "पूरा हुआ";
  @override
  String get pending => "लंबित";
  @override
  String get appTheme => "ऐप थीम";
  @override
  String get chooseThemeAppearance => "अपनी पसंदीदा थीम चुनें";
  @override
  String get lightMode => "लाइट मोड";
  @override
  String get lightModeSubtitle => "हमेशा साफ़ लाइट थीम का उपयोग करें";
  @override
  String get darkMode => "डार्क मोड";
  @override
  String get darkModeSubtitle => "हमेशा डार्क थीम का उपयोग करें";
  @override
  String get systemDefault => "सिस्टम डिफ़ॉल्ट";
  @override
  String get systemDefaultSubtitle =>
      "डिवाइस की सेटिंग के अनुसार स्वचालित रूप से बदलें";
  @override
  String get language => "भाषा";
  @override
  String get appLanguage => "ऐप की भाषा";
  @override
  String get choosePreferredLanguage => "अपनी पसंदीदा भाषा चुनें";
  @override
  String get accountSettings => "खाता सेटिंग्स";
  @override
  String get notifications => "सूचनाएं";
  @override
  String get notificationSettings => "सूचना सेटिंग्स";
  @override
  String get pushNotifications => "पुश सूचनाएं";
  @override
  String get notificationsEnabledSubtitle => "सूचनाएं सक्षम हैं";
  @override
  String get notificationsDisabledSubtitle => "सभी कार्य अलर्ट अक्षम हैं";
  @override
  String get defaultReminderTiming => "डिफ़ॉल्ट रिमाइंडर समय";
  @override
  String get atDueTime => "नियत समय पर";
  @override
  String get fiveMinsBefore => "5 मिनट पहले";
  @override
  String get fifteenMinsBefore => "15 मिनट पहले";
  @override
  String get alertStyle => "अलर्ट शैली";
  @override
  String get soundAlert => "ध्वनि अलर्ट";
  @override
  String get vibrationAlert => "कंपन अलर्ट";
  @override
  String get sendTestNotification => "परीक्षण सूचना भेजें";
  @override
  String get testNotificationSent =>
      "परीक्षण सूचना भेजी गई! अपनी सूचना ट्रे जांचें।";
  @override
  String get aboutUs => "हमारे बारे में";
  @override
  String get privacyPolicy => "गोपनीयता नीति";
  @override
  String get logout => "लॉग आउट";
  @override
  String get logoutConfirmation =>
      "क्या आप निश्चित रूप से लॉग आउट करना चाहते हैं?";
  @override
  String get logoutMessage =>
      "अपने कार्यों तक पहुंचने के लिए आपको फिर से लॉग इन करना होगा।";
  @override
  String get profilePictureUpdated =>
      "प्रोफ़ाइल चित्र सफलतापूर्वक अपडेट किया गया!";

  // Home Screen
  @override
  String get hello => "नमस्ते";
  @override
  String get pendingTasksMsg => "लंबित कार्य हैं";
  @override
  String get dailyCompletion => "दैनिक प्रगति";
  @override
  String get doneTasks => "पूर्ण";
  @override
  String get completedOfTotal => "कुल कार्यों में से पूरा हुआ";
  @override
  String get searchHint => "शीर्षक या नोट द्वारा कार्य खोजें...";
  @override
  String get noTasksFound => "कोई कार्य नहीं मिला";
  @override
  String get tapToCreateTask =>
      "नया कार्य बनाने के लिए \"+ कार्य जोड़ें\" बटन पर टैप करें।";
  @override
  String get completedTasksSection => "पूर्ण किए गए कार्य";
  @override
  String get editTask => "कार्य संपादित करें";
  @override
  String get deleteTask => "कार्य हटाएं";
  @override
  String get deleteTaskConfirmation =>
      "क्या आप निश्चित रूप से इस कार्य को हटाना चाहते हैं?";

  // Add/Edit Task Bottom Sheet
  @override
  String get addNewTask => "नया कार्य जोड़ें";
  @override
  String get taskTitleHint => "कार्य का शीर्षक";
  @override
  String get taskDescriptionHint => "विवरण (वैकल्पिक)";
  @override
  String get selectCategory => "श्रेणी चुनें";
  @override
  String get selectPriority => "प्राथमिकता चुनें";
  @override
  String get dueDateTime => "नियत तिथि और समय";
  @override
  String get selectDate => "तारीख चुनें";
  @override
  String get selectTime => "समय चुनें";
  @override
  String get createTask => "कार्य बनाएं";
  @override
  String get updateTask => "कार्य अपडेट करें";

  // Categories (Firebase & UI)
  @override
  String get all => "सभी";
  @override
  String get work => "कार्य";
  @override
  String get personal => "व्यक्तिगत";
  @override
  String get shopping => "खरीदारी";
  @override
  String get fitness => "फिटनेस";
  @override
  String get other => "अन्य";

  // Priority (Firebase & UI)
  @override
  String get high => "उच्च";
  @override
  String get medium => "मध्यम";
  @override
  String get low => "निम्न";

  // Status (Firebase & UI)
  @override
  String get statusPending => "लंबित";
  @override
  String get statusCompleted => "पूर्ण";

  // Bottom Navigation
  @override
  String get home => "होम";
}
