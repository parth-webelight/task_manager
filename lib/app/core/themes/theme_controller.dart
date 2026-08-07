import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'app_theme.dart';

/// GetX Controller for managing App Light/Dark/System Theme state & persistence
class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  static const String _themeModeKey = 'theme_mode_str';
  static const String _colorSchemeKey = 'color_scheme_str';

  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  final Rx<AppColorScheme> _colorScheme = AppColorScheme.indigo.obs;
  AppColorScheme get colorScheme => _colorScheme.value;

  String get currentThemeName {
    final modeName = switch (_themeMode.value) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System Default',
    };
    final colorName = AppColors.getColorSchemeName(_colorScheme.value);
    return '$modeName ($colorName)';
  }

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPrefs();
  }

  /// Load persisted theme setting from SharedPreferences
  Future<void> loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeModeKey);
      final savedScheme = prefs.getString(_colorSchemeKey);

      if (savedTheme == 'light') {
        _themeMode.value = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        _themeMode.value = ThemeMode.dark;
      } else {
        _themeMode.value = ThemeMode.system;
      }

      if (savedScheme == 'emerald') {
        _colorScheme.value = AppColorScheme.emerald;
      } else if (savedScheme == 'orange') {
        _colorScheme.value = AppColorScheme.orange;
      } else {
        _colorScheme.value = AppColorScheme.indigo;
      }

      Get.changeThemeMode(_themeMode.value);
      _applyThemeData();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// Apply current ThemeData dynamically to GetX
  void _applyThemeData() {
    final isDark = _themeMode.value == ThemeMode.dark ||
        (_themeMode.value == ThemeMode.system &&
            Get.context != null &&
            MediaQuery.of(Get.context!).platformBrightness == Brightness.dark);

    final targetTheme = isDark
        ? AppTheme.getDarkTheme(_colorScheme.value)
        : AppTheme.getLightTheme(_colorScheme.value);

    Get.changeTheme(targetTheme);
    Get.forceAppUpdate();
  }

  /// Explicitly set theme mode (Light, Dark, or System)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeStr = 'system';
      if (mode == ThemeMode.light) {
        modeStr = 'light';
      } else if (mode == ThemeMode.dark) {
        modeStr = 'dark';
      }
      await prefs.setString(_themeModeKey, modeStr);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }

    _applyThemeData();
  }

  /// Set dynamic Color Scheme (Classic Indigo, Emerald Green, Deep Purple)
  Future<void> setColorScheme(AppColorScheme scheme) async {
    _colorScheme.value = scheme;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_colorSchemeKey, scheme.name);
    } catch (e) {
      debugPrint('Error saving color scheme preference: $e');
    }

    _applyThemeData();
  }
}
