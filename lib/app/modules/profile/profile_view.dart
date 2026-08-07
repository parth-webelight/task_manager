import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/modules/home/home_controller.dart';
import 'package:task_manager/app/modules/profile/profile_controller.dart';
import 'package:task_manager/app/localizations/language.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkScaffoldBackground
          : AppColors.lightScaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              // Profile Header Card
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey.shade300)
                            .withAlpha(40),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Interactive Avatar with Gradient ring & Camera Badge
                      GestureDetector(
                        onTap: controller.showImagePickerOptions,
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          AppColors.darkPrimary,
                                          AppColors.darkSecondary,
                                        ]
                                      : [
                                          AppColors.lightPrimary,
                                          AppColors.lightSecondary,
                                        ],
                                ),
                              ),
                              child: Obx(() {
                                if (controller.isUploadingImage.value) {
                                  return CircleAvatar(
                                    radius: 40.r,
                                    backgroundColor: isDark
                                        ? AppColors.darkScaffoldBackground
                                        : AppColors.lightScaffoldBackground,
                                    child: SizedBox(
                                      width: 28.r,
                                      height: 28.r,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: primaryColor,
                                      ),
                                    ),
                                  );
                                }

                                final base64Str =
                                    controller.userPhotoBase64.value;
                                if (base64Str.isNotEmpty) {
                                  try {
                                    final bytes = base64Decode(base64Str);
                                    return CircleAvatar(
                                      radius: 40.r,
                                      backgroundColor: isDark
                                          ? AppColors.darkScaffoldBackground
                                          : AppColors.lightScaffoldBackground,
                                      backgroundImage: MemoryImage(bytes),
                                    );
                                  } catch (e) {
                                    debugPrint('Base64 decode error: $e');
                                  }
                                }

                                return CircleAvatar(
                                  radius: 40.r,
                                  backgroundColor: isDark
                                      ? AppColors.darkScaffoldBackground
                                      : AppColors.lightScaffoldBackground,
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 46.r,
                                    color: primaryColor,
                                  ),
                                );
                              }),
                            ),

                            // Camera Edit Badge
                            Positioned(
                              bottom: 2.r,
                              right: 2.r,
                              child: Container(
                                padding: EdgeInsets.all(7.r),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cardBg, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(50),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14.r,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 14.h),

                      Obx(
                        () => Text(
                          controller.userName.value,
                          style: AppTextStyles.bold(
                            fontSize: 20.sp,
                            color: isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Obx(
                        () => Text(
                          controller.userEmail.value,
                          style: AppTextStyles.regular(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Overview Stats Grid
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildStatTile(
                          isDark: isDark,
                          cardBg: cardBg,
                          title: lang?.totalTasks ?? 'Total Tasks',
                          count: '${homeController.tasks.length}',
                          icon: Icons.assignment_rounded,
                          color: AppColors.categoryWork,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => _buildStatTile(
                          isDark: isDark,
                          cardBg: cardBg,
                          title: lang?.completed ?? 'Completed',
                          count: '${homeController.completedTasksCount}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.statusCompleted,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => _buildStatTile(
                          isDark: isDark,
                          cardBg: cardBg,
                          title: lang?.pending ?? 'Pending',
                          count: '${homeController.pendingTasksCount}',
                          icon: Icons.pending_actions_rounded,
                          color: AppColors.statusPending,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Options & Settings List
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildProfileOptionTile(
                        isDark: isDark,
                        icon: Icons.palette_outlined,
                        title: lang?.appTheme ?? 'App Theme',
                        onTap: controller.showThemeSelectionBottomSheet,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                      _buildProfileOptionTile(
                        isDark: isDark,
                        icon: Icons.person_outline_rounded,
                        title: lang?.accountSettings ?? 'Account Settings',
                        onTap: controller.showAccountSettingsBottomSheet,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                      _buildProfileOptionTile(
                        isDark: isDark,
                        icon: Icons.notifications_none_rounded,
                        title: lang?.notifications ?? 'Notifications',
                        onTap: controller.showNotificationSettingsBottomSheet,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                      _buildProfileOptionTile(
                        isDark: isDark,
                        icon: Icons.shield_outlined,
                        title: lang?.privacyPolicy ?? 'Privacy & Policy',
                        onTap: () {},
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider,
                      ),
                      _buildProfileOptionTile(
                        isDark: isDark,
                        icon: Icons.logout_rounded,
                        title: lang?.logout ?? 'Logout',
                        isDestructive: true,
                        onTap: controller.confirmLogout,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Stat Card Helper
  Widget _buildStatTile({
    required bool isDark,
    required Color cardBg,
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 8.h),
          Text(
            count,
            style: AppTextStyles.bold(
              fontSize: 18.sp,
              color: isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: AppTextStyles.regular(
              fontSize: 11.sp,
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // Profile Option ListTile Helper
  Widget _buildProfileOptionTile({
    required bool isDark,
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.priorityHigh
        : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText);

    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive
            ? AppColors.priorityHigh
            : (isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText),
        size: 22.r,
      ),
      title: Text(
        title,
        style: AppTextStyles.medium(fontSize: 15.sp, color: color),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: AppTextStyles.regular(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
            SizedBox(width: 6.w),
          ],
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.r,
            color: isDark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
        ],
      ),
    );
  }
}
