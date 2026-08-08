import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/core/themes/theme_controller.dart';
import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/core/utils/session_manager.dart';
import 'package:task_manager/app/core/widgets/common_dialog.dart';
import 'package:task_manager/app/modules/home/home_controller.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'package:task_manager/app/services/auth_service.dart';
import 'package:task_manager/app/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileController extends GetxController {
  final userName = 'Task Master'.obs;
  final userEmail = 'user@taskmanager.com'.obs;
  final userPhotoBase64 = ''.obs;
  final isUploadingImage = false.obs;

  // Notification Settings State
  final isNotificationsEnabled = true.obs;
  final reminderMinutes = 5.obs;
  final isSoundEnabled = true.obs;
  final isVibrationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadNotificationSettings();
  }

  void _loadNotificationSettings() {
    final notifService = NotificationService();
    isNotificationsEnabled.value = notifService.isNotificationsEnabled;
    int mins = notifService.reminderMinutes;
    if (mins > 15) {
      mins = 15;
      notifService.setReminderMinutes(15);
    }
    reminderMinutes.value = mins;
    isSoundEnabled.value = notifService.isSoundEnabled;
    isVibrationEnabled.value = notifService.isVibrationEnabled;
  }

  Future<void> _loadUserData() async {
    final session = SessionManager();
    final localPhoto = await session.getStringValue(
      SessionManager.userPhotoBase64,
    );
    if (localPhoto.isNotEmpty) {
      userPhotoBase64.value = localPhoto;
    }

    final firebaseUser = AuthService.currentUser;
    if (firebaseUser != null) {
      if (firebaseUser.displayName != null &&
          firebaseUser.displayName!.isNotEmpty) {
        userName.value = firebaseUser.displayName!;
      }
      if (firebaseUser.email != null && firebaseUser.email!.isNotEmpty) {
        userEmail.value = firebaseUser.email!;
      }

      // Fetch photoBase64 from Firestore if not stored locally
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['photoBase64'] != null &&
              data['photoBase64'].toString().isNotEmpty) {
            final photoStr = data['photoBase64'].toString();
            userPhotoBase64.value = photoStr;
            await session.setStringValue(
              SessionManager.userPhotoBase64,
              photoStr,
            );
          }
        }
      } catch (e) {
        debugPrint('Firestore photo fetch warning: $e');
      }
    }

    final name = await session.getStringValue(SessionManager.userName);
    final email = await session.getStringValue(SessionManager.userEmail);

    if (name.isNotEmpty) {
      userName.value = name;
    }
    if (email.isNotEmpty) {
      userEmail.value = email;
    }
  }

  /// Show Bottom Sheet to choose Camera or Gallery for Profile Photo
  void showImagePickerOptions() {
    final isDark = Get.isDarkMode;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkDivider
                      : AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Change Profile Picture',
              style: AppTextStyles.bold(
                fontSize: 18.sp,
                color: isDark
                    ? AppColors.darkPrimaryText
                    : AppColors.lightPrimaryText,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Select an image source to update your profile photo',
              style: AppTextStyles.regular(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _buildPickerOptionTile(
                    isDark: isDark,
                    icon: Icons.photo_library_rounded,
                    title: 'Gallery',
                    onTap: () {
                      Get.back();
                      pickAndUploadProfileImage(ImageSource.gallery);
                    },
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: _buildPickerOptionTile(
                    isDark: isDark,
                    icon: Icons.camera_alt_rounded,
                    title: 'Camera',
                    onTap: () {
                      Get.back();
                      pickAndUploadProfileImage(ImageSource.camera);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOptionTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkScaffoldBackground
              : AppColors.lightScaffoldBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: activeColor, size: 28.r),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.darkPrimaryText
                    : AppColors.lightPrimaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick Image, convert to Base64, and save in Firestore database
  Future<void> pickAndUploadProfileImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      isUploadingImage.value = true;

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      final firebaseUser = AuthService.currentUser;
      final session = SessionManager();
      final uid = firebaseUser?.uid ?? (await session.getUserID());

      if (uid.isNotEmpty) {
        await AuthService.updateUserProfileImage(
          uid: uid,
          base64Image: base64String,
        );
        userPhotoBase64.value = base64String;

        Get.find<AlertMessageUtils>().showCustomSnackBar(
          message: 'Profile picture update successfully!',
        );
      } else {
        Get.find<AlertMessageUtils>().showCustomSnackBar(
          message: 'User session not found. Please re-login.',
        );
      }
    } catch (e) {
      debugPrint('Profile image upload error: $e');
      Get.find<AlertMessageUtils>().showCustomSnackBar(
        message: 'Failed to update profile picture: $e',
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// Open App Theme Selection Bottom Sheet (Appearance Mode + Color Scheme)
  void showThemeSelectionBottomSheet() {
    final themeController = Get.find<ThemeController>();
    final isDark = Get.isDarkMode;

    // Temporary local state - changes are only applied when 'Apply & Done' is pressed
    final tempSelectedMode = themeController.themeMode.obs;
    final tempSelectedScheme = themeController.colorScheme.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'App Theme & Color Palette',
                style: AppTextStyles.bold(
                  fontSize: 18.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
              SizedBox(height: 18.h),

              // SECTION 1: APPEARANCE MODE
              Text(
                'Appearance Mode',
                style: AppTextStyles.bold(
                  fontSize: 14.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
              SizedBox(height: 10.h),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildModeChip(
                        title: 'Light',
                        mode: ThemeMode.light,
                        currentMode: tempSelectedMode.value,
                        isDark: isDark,
                        onTap: () => tempSelectedMode.value = ThemeMode.light,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildModeChip(
                        title: 'Dark',
                        mode: ThemeMode.dark,
                        currentMode: tempSelectedMode.value,
                        isDark: isDark,
                        onTap: () => tempSelectedMode.value = ThemeMode.dark,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildModeChip(
                        title: 'System',
                        mode: ThemeMode.system,
                        currentMode: tempSelectedMode.value,
                        isDark: isDark,
                        onTap: () => tempSelectedMode.value = ThemeMode.system,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // SECTION 2: COLOR SCHEME PRESETS
              Text(
                'Color Scheme Theme',
                style: AppTextStyles.bold(
                  fontSize: 14.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
              SizedBox(height: 10.h),

              // 1. Classic Indigo
              Obx(
                () => _buildColorSchemeTile(
                  title: 'Classic Indigo',
                  subtitle: 'Modern Indigo Blue Palette',
                  accentColor: const Color(0xFF4F46E5),
                  scheme: AppColorScheme.indigo,
                  currentScheme: tempSelectedScheme.value,
                  isDark: isDark,
                  onTap: () {
                    tempSelectedScheme.value = AppColorScheme.indigo;
                  },
                ),
              ),
              SizedBox(height: 8.h),

              // 2. Emerald Green
              Obx(
                () => _buildColorSchemeTile(
                  title: 'Emerald Green',
                  subtitle: 'Fresh Forest Green Palette',
                  accentColor: const Color(0xFF059669),
                  scheme: AppColorScheme.emerald,
                  currentScheme: tempSelectedScheme.value,
                  isDark: isDark,
                  onTap: () {
                    tempSelectedScheme.value = AppColorScheme.emerald;
                  },
                ),
              ),
              SizedBox(height: 8.h),

              // 3. Sunset Orange
              Obx(
                () => _buildColorSchemeTile(
                  title: 'Sunset Orange',
                  subtitle: 'Warm Sunset Orange Palette',
                  accentColor: const Color(0xFFEA580C),
                  scheme: AppColorScheme.orange,
                  currentScheme: tempSelectedScheme.value,
                  isDark: isDark,
                  onTap: () {
                    tempSelectedScheme.value = AppColorScheme.orange;
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Apply & Done Button
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () async {
                    await themeController.setThemeMode(tempSelectedMode.value);
                    await themeController.setColorScheme(
                      tempSelectedScheme.value,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Apply & Done',
                    style: AppTextStyles.bold(fontSize: 15.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildModeChip({
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = currentMode == mode;
    final primaryColor = Theme.of(Get.context!).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withAlpha(30)
              : (isDark
                    ? AppColors.darkScaffoldBackground
                    : AppColors.lightScaffoldBackground),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.bold(
              fontSize: 12.sp,
              color: isSelected
                  ? primaryColor
                  : (isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSchemeTile({
    required String title,
    required String subtitle,
    required Color accentColor,
    required AppColorScheme scheme,
    required AppColorScheme currentScheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = currentScheme == scheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withAlpha(25)
              : (isDark
                    ? AppColors.darkScaffoldBackground
                    : AppColors.lightScaffoldBackground),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: accentColor.withAlpha(80), blurRadius: 6),
                ],
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bold(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.regular(
                      fontSize: 11.5.sp,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.radio_button_checked_rounded,
                color: accentColor,
                size: 20.r,
              )
            else
              Icon(
                Icons.radio_button_unchecked_rounded,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }

  void confirmLogout() {
    CommonDialog.showLogoutDialog(
      onLogout: () async {
        await AuthService.signOut();
        Get.find<AlertMessageUtils>().showCustomSnackBar(
          message: 'Logged out successfully',
        );
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  void confirmDeleteAccount() {
    CommonDialog.showConfirmDialog(
      title: 'Delete Account',
      message: 'Are you sure you want to permanently delete your account?',
      icon: Icons.delete_forever_rounded,
      iconColor: AppColors.priorityHigh,
      yesText: 'Delete',
      noText: 'Cancel',
      onYes: () async {
        try {
          await AuthService.deleteAccount();
          Get.find<AlertMessageUtils>().showCustomSnackBar(
            message: 'Your account has been deleted successfully.',
          );
          Get.offAllNamed(Routes.LOGIN);
        } catch (e) {
          debugPrint('Delete Account Error: $e');
          Get.find<AlertMessageUtils>().showCustomSnackBar(
            message: AuthService.getReadableErrorMessage(e),
          );
        }
      },
    );
  }

  /// Open Notification Settings Bottom Sheet
  void showNotificationSettingsBottomSheet() {
    final isDark = Get.isDarkMode;

    final timingOptions = [
      {'minutes': 0, 'label': 'At Due Time'},
      {'minutes': 5, 'label': '5 Mins Before'},
      {'minutes': 15, 'label': '15 Mins Before'},
    ];

    // Local temporary state - changes are only saved when 'Save Settings' button is tapped
    final tempNotificationsEnabled = isNotificationsEnabled.value.obs;
    final tempReminderMinutes = reminderMinutes.value.obs;
    final tempSoundEnabled = isSoundEnabled.value.obs;
    final tempVibrationEnabled = isVibrationEnabled.value.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle bar
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Title Header
              Row(
                children: [
                  Text(
                    'Notification Settings',
                    style: AppTextStyles.bold(
                      fontSize: 18.sp,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // 1. Master Switch Card
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkScaffoldBackground
                        : AppColors.lightScaffoldBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tempNotificationsEnabled.value
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: tempNotificationsEnabled.value
                            ? (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                            : AppColors.priorityHigh,
                        size: 22.r,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Push Notifications',
                              style: AppTextStyles.bold(
                                fontSize: 15.sp,
                                color: isDark
                                    ? AppColors.darkPrimaryText
                                    : AppColors.lightPrimaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: tempNotificationsEnabled.value,
                        activeTrackColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        onChanged: (val) {
                          tempNotificationsEnabled.value = val;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 18.h),

              // Options section visible when Master Switch is ON
              Obx(() {
                if (!tempNotificationsEnabled.value) {
                  return const SizedBox.shrink();
                }

                final primaryColor = isDark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ⏰ 2. Reminder Timing Options
                    Text(
                      'Default Reminder Timing',
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    Obx(
                      () => Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: timingOptions.map((opt) {
                          final mins = opt['minutes'] as int;
                          final label = opt['label'] as String;
                          final isSelected = tempReminderMinutes.value == mins;

                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: primaryColor,
                            backgroundColor: isDark
                                ? AppColors.darkScaffoldBackground
                                : AppColors.lightScaffoldBackground,
                            labelStyle: AppTextStyles.medium(
                              fontSize: 12.sp,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? AppColors.darkPrimaryText
                                        : AppColors.lightPrimaryText),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              side: BorderSide(
                                color: isSelected
                                    ? primaryColor
                                    : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                tempReminderMinutes.value = mins;
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // 3. Sound & Vibration Controls
                    Text(
                      'Alert Style',
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkScaffoldBackground
                            : AppColors.lightScaffoldBackground,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Sound Toggle
                          Obx(
                            () => ListTile(
                              leading: Icon(
                                Icons.volume_up_rounded,
                                color: primaryColor,
                                size: 20.r,
                              ),
                              title: Text(
                                'Sound Alert',
                                style: AppTextStyles.medium(
                                  fontSize: 14.sp,
                                  color: isDark
                                      ? AppColors.darkPrimaryText
                                      : AppColors.lightPrimaryText,
                                ),
                              ),
                              trailing: Switch.adaptive(
                                value: tempSoundEnabled.value,
                                activeTrackColor: primaryColor,
                                onChanged: (val) {
                                  tempSoundEnabled.value = val;
                                },
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                          // Vibration Toggle
                          Obx(
                            () => ListTile(
                              leading: Icon(
                                Icons.vibration_rounded,
                                color: primaryColor,
                                size: 20.r,
                              ),
                              title: Text(
                                'Vibration Alert',
                                style: AppTextStyles.medium(
                                  fontSize: 14.sp,
                                  color: isDark
                                      ? AppColors.darkPrimaryText
                                      : AppColors.lightPrimaryText,
                                ),
                              ),
                              trailing: Switch.adaptive(
                                value: tempVibrationEnabled.value,
                                activeTrackColor: primaryColor,
                                onChanged: (val) {
                                  tempVibrationEnabled.value = val;
                                  if (val) {
                                    HapticFeedback.heavyImpact();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              SizedBox(height: 20.h),

              // Save Settings Button
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () async {
                    isNotificationsEnabled.value =
                        tempNotificationsEnabled.value;
                    reminderMinutes.value = tempReminderMinutes.value;
                    isSoundEnabled.value = tempSoundEnabled.value;
                    isVibrationEnabled.value = tempVibrationEnabled.value;

                    final notifService = NotificationService();
                    await notifService.setNotificationsEnabled(
                      tempNotificationsEnabled.value,
                    );
                    await notifService.setReminderMinutes(
                      tempReminderMinutes.value,
                    );
                    await notifService.setSoundEnabled(tempSoundEnabled.value);
                    await notifService.setVibrationEnabled(
                      tempVibrationEnabled.value,
                    );

                    Get.back();
                    Get.find<AlertMessageUtils>().showCustomSnackBar(
                      message: 'Notification settings saved!',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Save Settings',
                    style: AppTextStyles.bold(fontSize: 15.sp),
                  ),
                ),
              ),

              /*
              SizedBox(height: 12.h),

              // Test Notification Button
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await NotificationService().sendTestNotification();
                    Get.find<AlertMessageUtils>().showCustomSnackBar(
                      message: 'Test notification sent!',
                    );
                  },
                  icon: Icon(Icons.notifications_active_rounded, size: 18.r),
                  label: Text(
                    'Send Test Notification',
                    style: AppTextStyles.bold(fontSize: 14.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              */
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Account Settings Options Bottom Sheet
  void showAccountSettingsBottomSheet() {
    final isDark = Get.isDarkMode;
    final cardBg = isDark
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkScaffoldBackground
              : AppColors.lightScaffoldBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Account Settings',
                  style: AppTextStyles.bold(
                    fontSize: 20.sp,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  Obx(
                    () => ListTile(
                      onTap: () {
                        Get.back();
                        showEditNameDialog();
                      },
                      leading: Icon(
                        Icons.edit_rounded,
                        color: primaryColor,
                        size: 22.r,
                      ),
                      title: Text(
                        'Edit Name',
                        style: AppTextStyles.medium(
                          fontSize: 15.sp,
                          color: isDark
                              ? AppColors.darkPrimaryText
                              : AppColors.lightPrimaryText,
                        ),
                      ),
                      subtitle: Text(
                        userName.value,
                        style: AppTextStyles.regular(
                          fontSize: 13.sp,
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14.r,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                  ),
                  ListTile(
                    onTap: () {
                      Get.back();
                      showChangePasswordDialog();
                    },
                    leading: Icon(
                      Icons.lock_reset_rounded,
                      color: primaryColor,
                      size: 22.r,
                    ),
                    title: Text(
                      'Change Password',
                      style: AppTextStyles.medium(
                        fontSize: 15.sp,
                        color: isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                      ),
                    ),
                    subtitle: Text(
                      'Update your account password',
                      style: AppTextStyles.regular(
                        fontSize: 13.sp,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.r,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Show Dialog to Edit Name
  void showEditNameDialog() {
    final isDark = Get.isDarkMode;
    final nameController = TextEditingController(text: userName.value);
    final alerts = Get.find<AlertMessageUtils>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Name',
                style: AppTextStyles.bold(
                  fontSize: 18.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
              SizedBox(height: 14.h),
              TextField(
                controller: nameController,
                autofocus: true,
                maxLength: 40,
                style: AppTextStyles.medium(
                  fontSize: 14.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.medium(
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () async {
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) {
                        alerts.showErrorSnackBar(
                          title: 'Name Required',
                          message: 'Please enter a valid name.',
                        );
                        return;
                      }

                      Get.back();

                      // 1. Instant Local UI Update (0ms Delay)
                      final oldName = userName.value;
                      userName.value = newName;
                      if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().userName.value = newName;
                      }

                      // 2. Network & Firestore update in background
                      try {
                        final user = AuthService.currentUser;
                        String uid =
                            user?.uid ?? await SessionManager().getUserID();
                        await AuthService.updateUserName(
                          uid: uid,
                          name: newName,
                        );

                        alerts.showSuccessSnackBar(
                          title: 'Name Updated',
                          message: 'Your name has been updated to "$newName".',
                        );
                      } catch (e) {
                        // Revert on error
                        userName.value = oldName;
                        if (Get.isRegistered<HomeController>()) {
                          Get.find<HomeController>().userName.value = oldName;
                        }
                        alerts.showErrorSnackBar(
                          title: 'Update Failed',
                          message: e.toString(),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: Colors.white,
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

  /// Show Dialog to Change Password
  void showChangePasswordDialog() {
    final isDark = Get.isDarkMode;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isCurrentPasswordVisible = false.obs;
    final isNewPasswordVisible = false.obs;
    final isConfirmPasswordVisible = false.obs;
    final alerts = Get.find<AlertMessageUtils>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Password',
                  style: AppTextStyles.bold(
                    fontSize: 18.sp,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                  ),
                ),
                SizedBox(height: 14.h),
                Obx(
                  () => TextField(
                    controller: currentPasswordController,
                    obscureText: !isCurrentPasswordVisible.value,
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      hintText: 'Enter current password',
                      prefixIcon: const Icon(Icons.lock_clock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCurrentPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => isCurrentPasswordVisible.toggle(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      final email = userEmail.value.isNotEmpty
                          ? userEmail.value
                          : AuthService.currentUser?.email ?? '';
                      if (email.isEmpty) {
                        alerts.showErrorSnackBar(
                          title: 'Email Not Found',
                          message:
                              'User email is not available to send reset link.',
                        );
                        return;
                      }

                      Get.back();
                      try {
                        await AuthService.sendPasswordResetEmail(email);
                        showPasswordResetSentDialog(email);
                      } catch (e) {
                        alerts.showErrorSnackBar(
                          title: 'Failed to Send Link',
                          message: AuthService.getReadableErrorMessage(e),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.h,
                        horizontal: 0,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot current password?',
                      style: AppTextStyles.medium(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => TextField(
                    controller: newPasswordController,
                    obscureText: !isNewPasswordVisible.value,
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Minimum 6 characters',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isNewPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => isNewPasswordVisible.toggle(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(
                  () => TextField(
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible.value,
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter new password',
                      prefixIcon: const Icon(Icons.lock_clock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => isConfirmPasswordVisible.toggle(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.medium(
                          fontSize: 14.sp,
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () async {
                        final currentPass = currentPasswordController.text
                            .trim();
                        final newPass = newPasswordController.text.trim();
                        final confirmPass = confirmPasswordController.text
                            .trim();

                        if (currentPass.isEmpty) {
                          alerts.showErrorSnackBar(
                            title: 'Current Password Required',
                            message: 'Please enter your current password.',
                          );
                          return;
                        }

                        if (newPass.length < 6) {
                          alerts.showErrorSnackBar(
                            title: 'Weak Password',
                            message: 'Password must be at least 6 characters.',
                          );
                          return;
                        }

                        if (newPass != confirmPass) {
                          alerts.showErrorSnackBar(
                            title: 'Password Mismatch',
                            message: 'Passwords do not match.',
                          );
                          return;
                        }

                        Get.back();
                        try {
                          await AuthService.updatePassword(
                            currentPassword: currentPass,
                            newPassword: newPass,
                          );
                          alerts.showSuccessSnackBar(
                            title: 'Password Updated',
                            message:
                                'Your password has been changed successfully.',
                          );
                        } catch (e, stackTrace) {
                          debugPrint(
                            '[ProfileController] Change Password Error: $e',
                          );
                          debugPrint(
                            '[ProfileController] StackTrace: $stackTrace',
                          );
                          final readableMsg =
                              AuthService.getReadableErrorMessage(e);
                          alerts.showErrorSnackBar(
                            title: 'Update Failed',
                            message: readableMsg,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: AppTextStyles.bold(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show Detailed Guidance Dialog when Password Reset Email is Sent
  void showPasswordResetSentDialog(String email) {
    final isDark = Get.isDarkMode;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final alerts = Get.find<AlertMessageUtils>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        child: Padding(
          padding: EdgeInsets.all(22.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Ring Header
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_rounded,
                  color: primaryColor,
                  size: 34.r,
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                'Password Reset Link Sent!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bold(
                  fontSize: 18.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
              SizedBox(height: 10.h),

              // Subtitle with Email
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.regular(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'We have sent a reset password link to your email:\n',
                    ),
                    TextSpan(
                      text: email,
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // Instructions Box
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkScaffoldBackground
                      : AppColors.lightScaffoldBackground,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGuidanceStep(
                      icon: Icons.mark_email_unread_outlined,
                      text: 'Open your Email app (Gmail / Yahoo / Outlook)',
                      isDark: isDark,
                    ),
                    SizedBox(height: 10.h),
                    _buildGuidanceStep(
                      icon: Icons.folder_special_outlined,
                      text: 'Check your Inbox and SPAM / Junk folder',
                      isDark: isDark,
                      isHighlight: true,
                    ),
                    SizedBox(height: 10.h),
                    _buildGuidanceStep(
                      icon: Icons.touch_app_outlined,
                      text: 'Click the link in the email to set a new password',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Got It',
                    style: AppTextStyles.bold(
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () async {
                  try {
                    await AuthService.sendPasswordResetEmail(email);
                    alerts.showSuccessSnackBar(
                      title: 'Email Resent',
                      message: 'Password reset link resent to $email.',
                    );
                  } catch (e) {
                    alerts.showErrorSnackBar(
                      title: 'Resend Failed',
                      message: AuthService.getReadableErrorMessage(e),
                    );
                  }
                },
                child: Text(
                  'Didn\'t receive email? Resend',
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
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
    );
  }

  Widget _buildGuidanceStep({
    required IconData icon,
    required String text,
    required bool isDark,
    bool isHighlight = false,
  }) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Row(
      children: [
        Icon(
          icon,
          size: 18.r,
          color: isHighlight
              ? activeColor
              : (isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: isHighlight
                ? AppTextStyles.bold(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                  )
                : AppTextStyles.regular(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
          ),
        ),
      ],
    );
  }

  /// Open external Privacy Policy web link (Netlify)
  Future<void> openPrivacyPolicyUrl() async {
    final Uri url = Uri.parse('https://meet-vaghela-2003.netlify.app/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching Privacy Policy URL: $e');
      Get.find<AlertMessageUtils>().showCustomSnackBar(
        message: 'Could not open Privacy Policy link.',
      );
    }
  }

  /// Open Privacy & Policy Bottom Sheet
  void showPrivacyPolicyBottomSheet() {
    final isDark = Get.isDarkMode;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              Row(
                children: [
                  Icon(Icons.shield_outlined, color: primaryColor, size: 24.r),
                  SizedBox(width: 10.w),
                  Text(
                    'Privacy & Security Policy',
                    style: AppTextStyles.bold(
                      fontSize: 18.sp,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              Text(
                'Task Manager values your privacy. We are fully compliant with Google Play Store Safety Standards.',
                style: AppTextStyles.regular(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                ),
              ),
              SizedBox(height: 14.h),

              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkScaffoldBackground
                      : AppColors.lightScaffoldBackground,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildPrivacySummaryRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'Data Protection',
                      desc:
                          'Your tasks and personal info are encrypted in transit and at rest.',
                      isDark: isDark,
                    ),
                    SizedBox(height: 12.h),
                    _buildPrivacySummaryRow(
                      icon: Icons.do_not_disturb_on_outlined,
                      title: 'No Data Selling',
                      desc:
                          'We never sell, rent, or share your personal data with third parties.',
                      isDark: isDark,
                    ),
                    SizedBox(height: 12.h),
                    _buildPrivacySummaryRow(
                      icon: Icons.delete_outline_rounded,
                      title: 'Full User Control',
                      desc:
                          'You can delete your tasks or account anytime from your Profile screen.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Button to open Netlify Web Page directly
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    openPrivacyPolicyUrl();
                  },
                  icon: Icon(
                    Icons.open_in_browser_rounded,
                    color: primaryColor,
                    size: 18.r,
                  ),
                  label: Text(
                    'Open Online Privacy Policy Webpage',
                    style: AppTextStyles.bold(
                      fontSize: 13.sp,
                      color: primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Close & Accept',
                    style: AppTextStyles.bold(
                      fontSize: 15.sp,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPrivacySummaryRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: activeColor, size: 20.r),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bold(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                desc,
                style: AppTextStyles.regular(
                  fontSize: 11.5.sp,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
