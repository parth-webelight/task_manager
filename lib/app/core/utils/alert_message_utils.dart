import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';

class AlertMessageUtils {
  /// Base builder for creating professional themed Snackbars
  void _showStyledSnackBar({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    SnackPosition position = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Get.isDarkMode;

    final bgColor = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final titleColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final subtitleColor = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    Get.showSnackbar(
      GetSnackBar(
        snackPosition: position,
        duration: duration,
        animationDuration: const Duration(milliseconds: 400),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        padding: EdgeInsets.zero,
        messageText: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.lightPrimary).withAlpha(isDark ? 90 : 35),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Badge Container
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 14.w),

              // Title and Message text
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty) ...[
                      Text(
                        title,
                        style: AppTextStyles.bold(
                          fontSize: 15.sp,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                    Text(
                      message,
                      style: AppTextStyles.regular(
                        fontSize: 13.sp,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Close Icon Button
              GestureDetector(
                onTap: () {
                  if (Get.isSnackbarOpen) {
                    Get.back();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.r,
                    color: subtitleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Default SnackBar
  void showSnackBar({
    String title = '',
    String message = '',
    SnackPosition snackBarPosition = SnackPosition.TOP,
    Color? bgColor,
    Color? textColor,
  }) {
    _showStyledSnackBar(
      title: title,
      message: message,
      icon: Icons.notifications_none_rounded,
      iconColor: AppColors.lightPrimary,
      position: snackBarPosition,
    );
  }

  /// Success SnackBar
  void showSuccessSnackBar({
    String title = 'Success',
    required String message,
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showStyledSnackBar(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.statusCompleted,
      position: position,
    );
  }

  /// Error SnackBar
  void showErrorSnackBar({
    String title = 'Error',
    required String message,
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showStyledSnackBar(
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.priorityHigh,
      position: position,
    );
  }

  /// Warning SnackBar
  void showWarningSnackBar({
    String title = 'Warning',
    required String message,
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showStyledSnackBar(
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.priorityMedium,
      position: position,
    );
  }

  /// Info SnackBar
  void showInfoSnackBar({
    String title = 'Information',
    required String message,
    SnackPosition position = SnackPosition.TOP,
  }) {
    _showStyledSnackBar(
      title: title,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.categoryWork,
      position: position,
    );
  }

  /// Custom Floating Toast Message
  void showCustomSnackBar({
    String message = '',
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    showSuccessSnackBar(title: '', message: message, position: position);
  }

  /// Toast message bar
  void showToastMessages({String msg = ''}) {
    showInfoSnackBar(title: '', message: msg, position: SnackPosition.BOTTOM);
  }

  /// Show Loader Dialog
  void showLoaderDialog() {
    try {
      showDialog(
        context: Get.overlayContext!,
        barrierDismissible: false,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Center(
            child: Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SizedBox(
                height: 44.r,
                width: 44.r,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing loader dialog: $e');
    }
  }

  /// Hide Loader Dialog
  void hideLoaderDialog() {
    try {
      Navigator.of(Get.overlayContext!).pop();
    } catch (e) {
      debugPrint('Error hiding loader dialog: $e');
    }
  }
}
