import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart';

class SessionManager {
  static String auth_token = "auth_token";
  static String isLogin = "isLogin";
  static String isVerified = "isVerified";
  static String userID = "userID";
  static String role = "role";
  static String userName = "name";
  static String userEmail = "userEmail";
  static String phoneCode = "phoneCode";
  static String mobileNumber = "mobileNumber";
  static const String userPaymentOptions = "user_payment_options";
  static String birthDate = "birthDate";
  static String languageCode = "language_code";
  static String prefSelectedLanguageCode = "language";
  static String userData = "userData";

  /// Task Manager Session Variables
  static String userPhotoBase64 = "userPhotoBase64";


  Future<void> setUserData(String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userData, data);
  }

  Future<String?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userData);
  }

  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(userData);
  }

  Future<void> setStringValue(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> setUserCredentials(String email, String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userEmail, email);
  }

  Future<String> getUserPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userPassword') ?? '';
  }

  Future<void> setBoolValue(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<String> getStringValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String value;
    value = pref.getString(key) ?? "";
    return value;
  }

  Future<bool> getBoolValue(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool value;
    value = pref.getBool(key) ?? false;
    return value;
  }

  // Method to check if the user is logged in
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLogin) ?? false;
  }

  // Method to clear the session data (preserves user's preferred language setting)
  Future<void> onClearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(prefSelectedLanguageCode);
    await prefs.clear();
    if (savedLanguage != null && savedLanguage.isNotEmpty) {
      await prefs.setString(prefSelectedLanguageCode, savedLanguage);
    }
  }

  // Getters for user information
  Future<String> getUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userID) ?? '';
  }

  Future<String> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userName) ?? '';
  }

  Future<String> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmail) ?? '';
  }

  Future<String> getUserPaymentOptions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPaymentOptions) ?? '';
  }

  /// Save the mobile number
  Future<void> setMobileNumber(String mobile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(mobileNumber, mobile);
  }

  /// Retrieve the mobile number
  Future<String> getMobileNumber() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(mobileNumber) ?? '';
  }

  // Save the birthdate
  Future<void> setBirthDate(DateTime birthDate) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate =
        "${birthDate.day}/${birthDate.month}/${birthDate.year}";
    prefs.setString(SessionManager.birthDate, formattedDate);
  }

  Future<String> getBirthDate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SessionManager.birthDate) ?? '';
  }

  Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageCode, langCode);
  }



  Future<void> printSavedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {};
    prefs.getKeys().forEach((key) {
      data[key] = prefs.get(key); // Retrieve each key-value pair
    });
    debugPrint("Saved SharedPreferences Data: $data");
  }

  Future<Locale> setLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefSelectedLanguageCode, languageCode);
    return _locale(languageCode);
  }

  Future<String?> getSavedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefSelectedLanguageCode) ?? "en";
  }

  Future<String> getSavedLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefSelectedLanguageCode) ?? "en";
  }

  Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString(prefSelectedLanguageCode) ?? "en";
    return _locale(languageCode);
  }

  Locale _locale(String languageCode) {
    return languageCode.isNotEmpty
        ? Locale(languageCode, '')
        : const Locale('en', '');
  }

  void changeLanguage(BuildContext context, String selectedLanguageCode) async {
    var locale = await setLocale(selectedLanguageCode);
    MyApp.setLocale(context, locale);
  }
}
