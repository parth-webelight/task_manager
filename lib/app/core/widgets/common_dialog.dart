import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/localizations/language.dart';

class CommonDialog {
  /// Custom Logout Confirmation Dialog
  static void showLogoutDialog({
    required VoidCallback onLogout,
    String? title,
    String? message,
  }) {
    final isDark = Get.isDarkMode;
    final lang = Get.context != null ? Languages.of(Get.context!) : null;

    final dialogTitle = title ?? (lang?.logout ?? 'Logout');
    final dialogMessage = message ?? (lang?.logoutMessage ?? 'Are you sure you want to log out of your Task Manager account?');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade400).withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Logout Icon Badge
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.priorityHigh.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.priorityHigh,
                  size: 32.r,
                ),
              ),

              SizedBox(height: 18.h),

              // Title Text
              Text(
                dialogTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bold(
                  fontSize: 20.sp,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),

              SizedBox(height: 8.h),

              // Message Text
              Text(
                dialogMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(
                  fontSize: 14.sp,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),

              SizedBox(height: 24.h),

              // Action Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkScaffoldBackground
                              : AppColors.lightScaffoldBackground,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            lang?.cancel ?? 'Cancel',
                            style: AppTextStyles.semiBold(
                              fontSize: 14.sp,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Confirm Logout Button
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        onLogout();
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.priorityHigh,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.priorityHigh.withAlpha(80),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            lang?.logout ?? 'Logout',
                            style: AppTextStyles.bold(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Theme-adaptive General Confirm Dialog
  static void showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onYes,
    String yesText = 'Confirm',
    String noText = 'Cancel',
    IconData icon = Icons.help_outline_rounded,
    Color? iconColor,
  }) {
    final isDark = Get.isDarkMode;
    final primaryIconColor = iconColor ?? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade400).withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: primaryIconColor.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primaryIconColor,
                  size: 32.r,
                ),
              ),

              SizedBox(height: 18.h),

              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bold(
                  fontSize: 20.sp,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(
                  fontSize: 14.sp,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),

              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkScaffoldBackground
                              : AppColors.lightScaffoldBackground,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            noText,
                            style: AppTextStyles.semiBold(
                              fontSize: 14.sp,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        onYes();
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: primaryIconColor,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryIconColor.withAlpha(80),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            yesText,
                            style: AppTextStyles.bold(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Theme-adaptive Success Dialog
  static void showSuccessDialog({
    required String message,
    VoidCallback? onOk,
  }) {
    final isDark = Get.isDarkMode;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.statusCompleted,
                  size: 40.r,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Success!',
                style: AppTextStyles.bold(
                  fontSize: 20.sp,
                  color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(
                  fontSize: 14.sp,
                  color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                ),
              ),
              SizedBox(height: 24.h),
              InkWell(
                onTap: () {
                  Get.back();
                  if (onOk != null) onOk();
                },
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      'OK',
                      style: AppTextStyles.bold(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}