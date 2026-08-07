import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/modules/dashboard/dashboard_controller.dart';
import 'package:task_manager/app/modules/home/home_view.dart';
import 'package:task_manager/app/modules/home/widgets/add_task_bottom_sheet.dart';
import 'package:task_manager/app/modules/profile/profile_view.dart';
import 'package:task_manager/app/localizations/language.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark
          ? AppColors.darkScaffoldBackground
          : AppColors.lightScaffoldBackground,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedTabIndex.value,
          children: const [HomeView(), ProfileView()],
        ),
      ),
      bottomNavigationBar: isKeyboardOpen
          ? const SizedBox.shrink()
          : _buildCustomBottomNavBar(context, isDark),
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context, bool isDark) {
    final lang = Languages.of(context);
    final navBg = isDark
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: 12.h,
          top: 4.h,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: navBg,
          borderRadius: BorderRadius.circular(32.r),
          border: Border.all(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                .withAlpha(120),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey.shade400).withAlpha(
                isDark ? 90 : 60,
              ),
              blurRadius: 24,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: primaryColor.withAlpha(isDark ? 20 : 15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tab 1: Tasks
            Expanded(
              child: _buildNavItem(
                index: 0,
                icon: Icons.task_alt_rounded,
                activeIcon: Icons.task_alt_rounded,
                label: lang?.home ?? 'Tasks',
                isDark: isDark,
              ),
            ),

            // Center Action: Quick Add Task Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  AddTaskBottomSheet.show(context);
                },
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.darkPrimary, AppColors.darkSecondary]
                          : [AppColors.lightPrimary, AppColors.lightSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(110),
                        blurRadius: 14,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26.r,
                  ),
                ),
              ),
            ),

            // Tab 2: Profile
            Expanded(
              child: _buildNavItem(
                index: 1,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: lang?.profile ?? 'Profile',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    return Obx(() {
      final isSelected = controller.selectedTabIndex.value == index;
      final activeColor = isDark
          ? AppColors.darkPrimary
          : AppColors.lightPrimary;

      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          controller.changeTabIndex(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? activeColor
                      : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                  size: 22.r,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(
                      fontSize: 13.sp,
                      color: activeColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
