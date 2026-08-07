import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_controller.dart';

enum AppColorScheme { indigo, emerald, orange }

/// Centralized Color Palette for the Task Manager Application
class AppColors {
  AppColors._();

  // ==================== DYNAMIC COLOR SCHEME GETTERS ====================
  static Color getLightPrimary(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.indigo:
        return const Color(0xFF4F46E5);
      case AppColorScheme.emerald:
        return const Color(0xFF059669);
      case AppColorScheme.orange:
        return const Color(0xFFEA580C);
    }
  }

  static Color getLightSecondary(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.indigo:
        return const Color(0xFF6366F1);
      case AppColorScheme.emerald:
        return const Color(0xFF10B981);
      case AppColorScheme.orange:
        return const Color(0xFFF97316);
    }
  }

  static Color getDarkPrimary(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.indigo:
        return const Color(0xFF818CF8);
      case AppColorScheme.emerald:
        return const Color(0xFF34D399);
      case AppColorScheme.orange:
        return const Color(0xFFFB923C);
    }
  }

  static Color getDarkSecondary(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.indigo:
        return const Color(0xFF6366F1);
      case AppColorScheme.emerald:
        return const Color(0xFF10B981);
      case AppColorScheme.orange:
        return const Color(0xFFF97316);
    }
  }

  static String getColorSchemeName(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.indigo:
        return 'Classic Indigo';
      case AppColorScheme.emerald:
        return 'Emerald Green';
      case AppColorScheme.orange:
        return 'Sunset Orange';
    }
  }

  // ==================== LIGHT THEME COLORS ====================
  static Color get lightPrimary {
    if (Get.isRegistered<ThemeController>()) {
      return getLightPrimary(Get.find<ThemeController>().colorScheme);
    }
    return const Color(0xFF4F46E5);
  }

  static Color get lightSecondary {
    if (Get.isRegistered<ThemeController>()) {
      return getLightSecondary(Get.find<ThemeController>().colorScheme);
    }
    return const Color(0xFF6366F1);
  }

  static const Color lightScaffoldBackground = Color(0xFFF8FAFC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF111827);
  static const Color lightSecondaryText = Color(0xFF6B7280);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightBorder = Color(0xFFD1D5DB);

  // ==================== DARK THEME COLORS ====================
  static Color get darkPrimary {
    if (Get.isRegistered<ThemeController>()) {
      return getDarkPrimary(Get.find<ThemeController>().colorScheme);
    }
    return const Color(0xFF818CF8);
  }

  static Color get darkSecondary {
    if (Get.isRegistered<ThemeController>()) {
      return getDarkSecondary(Get.find<ThemeController>().colorScheme);
    }
    return const Color(0xFF6366F1);
  }

  static const Color darkScaffoldBackground = Color(0xFF0F172A);
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color darkPrimaryText = Color(0xFFF8FAFC);
  static const Color darkSecondaryText = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);

  // ==================== SPLASH & BACKGROUND GRADIENT COLORS ====================
  static const Color splashDarkGradientStart = Color(0xFF0F172A);
  static const Color splashDarkGradientMid = Color(0xFF1E1B4B);
  static const Color splashDarkGradientEnd = Color(0xFF0F172A);

  static const Color splashLightGradientStart = Color(0xFFF8FAFC);
  static const Color splashLightGradientMid = Color(0xFFEEF2FF);
  static const Color splashLightGradientEnd = Color(0xFFE0E7FF);

  // ==================== TASK PRIORITY COLORS ====================
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF22C55E);

  // ==================== TASK STATUS COLORS ====================
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusOverdue = Color(0xFFEF4444);

  // ==================== CATEGORY COLORS ====================
  static const Color categoryWork = Color(0xFF3B82F6);
  static const Color categoryLearning = Color(0xFF8B5CF6);
  static const Color categoryPersonal = Color(0xFFEC4899);
  static const Color categoryShopping = Color(0xFFF97316);
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryFinance = Color(0xFF14B8A6);

  // ==================== HELPER METHODS ====================
  /// Get Priority Color based on priority level string
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityLow;
    }
  }

  /// Get Status Color based on status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'complete':
      case 'done':
        return statusCompleted;
      case 'pending':
      case 'in_progress':
      case 'in progress':
        return statusPending;
      case 'overdue':
      case 'expired':
        return statusOverdue;
      default:
        return statusPending;
    }
  }

  /// Get Category Color based on category name string
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return categoryWork;
      case 'learning':
      case 'education':
      case 'study':
        return categoryLearning;
      case 'personal':
        return categoryPersonal;
      case 'shopping':
        return categoryShopping;
      case 'health':
      case 'fitness':
        return categoryHealth;
      case 'finance':
      case 'financial':
      case 'money':
        return categoryFinance;
      default:
        return categoryWork;
    }
  }
}

/// Backwards compatibility alias for existing code referencing `AppColor`
class AppColor extends AppColors {
  AppColor._() : super._();

  static Color get mainColor => AppColors.lightPrimary;
  static const Color blackColor = Color(0xFF111827);
  static Color get primaryColor => AppColors.lightPrimary;
  static Color get primary1Color => AppColors.lightSecondary;
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color whiteColor1 = Color(0xFFFCFDFC);
  static const Color secondaryColor = AppColors.lightScaffoldBackground;
  static const Color secondary1Color = Color(0xFFF3E5DA);
  static const Color dashboardColor = Color(0xFFFFFCFA);
  static const Color dashboardIconColor = Color(0xFFFFF5ED);
  static const Color redColor = AppColors.priorityHigh;
  static const Color greenText = AppColors.statusCompleted;
  static const Color greyColorText1 = AppColors.lightSecondaryText;
  static const Color dividerColor = AppColors.lightDivider;
  static const Color borderColor = AppColors.lightBorder;
  static const Color darkModeBgColor = AppColors.darkScaffoldBackground;
  static const Color darkModeCardBgColor = AppColors.darkCardBackground;

  // Splash Gradient Aliases
  static const Color splashDarkStart = AppColors.splashDarkGradientStart;
  static const Color splashDarkMid = AppColors.splashDarkGradientMid;
  static const Color splashDarkEnd = AppColors.splashDarkGradientEnd;
  static const Color splashLightStart = AppColors.splashLightGradientStart;
  static const Color splashLightMid = AppColors.splashLightGradientMid;
  static const Color splashLightEnd = AppColors.splashLightGradientEnd;
}
