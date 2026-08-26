import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/services/network_service.dart';

class ConnectivityBannerOverlay extends StatelessWidget {
  final Widget child;

  const ConnectivityBannerOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Obx(() {
          if (!Get.isRegistered<NetworkService>()) {
            return const SizedBox.shrink();
          }

          final networkService = NetworkService.to;
          final isOffline = !networkService.isConnected.value;
          final isRestored = networkService.showRestoredBanner.value;

          if (!isOffline && !isRestored) {
            return const SizedBox.shrink();
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;

          // 1. Show Green Restored Banner briefly at top when internet comes back ON
          if (isRestored && !isOffline) {
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.statusCompleted.withAlpha(180),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : Colors.grey.shade400).withAlpha(
                          isDark ? 100 : 50,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.statusCompleted.withAlpha(isDark ? 50 : 30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_rounded,
                            color: AppColors.statusCompleted,
                            size: 18.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Internet Connection Restored',
                            style: AppTextStyles.semiBold(
                              fontSize: 12.5.sp,
                              color: isDark ? Colors.white : const Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // 2. Non-dismissible Center Modal Pop-up when Internet is OFF
          final cardBg = isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground;

          final primaryTextColor = isDark
              ? AppColors.darkPrimaryText
              : AppColors.lightPrimaryText;

          final secondaryTextColor = isDark
              ? AppColors.darkSecondaryText
              : AppColors.lightSecondaryText;

          return PopScope(
            canPop: false, // Prevents back button from dismissing
            child: Material(
              color: Colors.black.withOpacity(0.65), // Dimmed backdrop overlay
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Wifi Off Icon Badge
                        Container(
                          padding: EdgeInsets.all(18.r),
                          decoration: BoxDecoration(
                            color: AppColors.priorityHigh.withAlpha(isDark ? 40 : 25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            color: AppColors.priorityHigh,
                            size: 42.r,
                          ),
                        ),
                        SizedBox(height: 18.h),

                        // Title
                        Text(
                          'No Internet Connection',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bold(
                            fontSize: 19.sp,
                            color: primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Subtitle Message
                        Text(
                          'Please check your network settings and turn on Wi-Fi or Mobile Data to continue using the app.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.regular(
                            fontSize: 13.5.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                        SizedBox(height: 22.h),

                        // Status Badge with Loading Spinner
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary)
                                .withAlpha(20),
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary)
                                  .withAlpha(60),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14.r,
                                height: 14.r,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lightPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Searching for connection...',
                                style: AppTextStyles.medium(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
