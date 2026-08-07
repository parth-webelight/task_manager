import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/core/utils/image_constant.dart';
import 'package:task_manager/app/modules/splash/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background Gradient decoration matching theme
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.splashDarkGradientStart,
                        AppColors.splashDarkGradientMid,
                        AppColors.splashDarkGradientEnd,
                      ]
                    : [
                        AppColors.splashLightGradientStart,
                        AppColors.splashLightGradientMid,
                        AppColors.splashLightGradientEnd,
                      ],
              ),
            ),
          ),

          // Animated Background Glowing Orbs
          Positioned(
            top: -60.h,
            right: -60.w,
            child: FadeInDown(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                width: 220.r,
                height: 220.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightPrimary.withAlpha(isDark ? 40 : 25),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -80.h,
            left: -60.w,
            child: FadeInUp(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                width: 260.r,
                height: 260.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightSecondary.withAlpha(isDark ? 35 : 20),
                ),
              ),
            ),
          ),

          // Main Center Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated Logo Container
                    ZoomIn(
                      duration: const Duration(milliseconds: 900),
                      child: Pulse(
                        duration: const Duration(milliseconds: 2000),
                        infinite: true,
                        child: Container(
                          width: 140.r,
                          height: 140.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lightPrimary.withAlpha(
                                  isDark ? 100 : 70,
                                ),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            icSplashLogo,
                            width: 140.r,
                            height: 140.r,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 36.h),

                    // App Title
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'TASK MANAGER',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.extraBold(
                          fontSize: 26.sp,
                          letterSpacing: 2.5,
                          color: isDark
                              ? AppColors.darkPrimaryText
                              : AppColors.lightPrimaryText,
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Tagline / Subtitle
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Organize & Complete Your Tasks',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.medium(
                          fontSize: 14.sp,
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom Animated Progress Bar / Indicator
                    FadeIn(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: 48.w,
                        height: 4.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2.r),
                          child: LinearProgressIndicator(
                            backgroundColor:
                                (isDark
                                        ? AppColors.darkDivider
                                        : AppColors.lightDivider)
                                    .withAlpha(120),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
