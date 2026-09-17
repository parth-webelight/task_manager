import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/core/widgets/custom_fillable_text_field.dart';
import 'package:task_manager/app/modules/forgot_password/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkScaffoldBackground
            : AppColors.lightScaffoldBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
              size: 20.r,
            ),
            onPressed: controller.backToLogin,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated Key/Lock Header Icon
                  ZoomIn(
                    duration: const Duration(milliseconds: 700),
                    child: Center(
                      child: Container(
                        width: 90.r,
                        height: 90.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                              .withAlpha(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightPrimary.withAlpha(
                                isDark ? 60 : 40,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 46.r,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Title Text
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold(
                        fontSize: 26.sp,
                        color: isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Subtitle Instructions
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'No worries! Enter your registered email address below to receive a password reset link.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regular(
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // Email Address Input Field
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Address',
                          style: AppTextStyles.medium(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomFillableTextField(
                          controller: controller.emailController,
                          hint: 'Enter your registered email address',
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          fillColor: fillColor,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Submit Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: Obx(
                      () => SizedBox(
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.sendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            foregroundColor: isDark
                                ? AppColors.darkScaffoldBackground
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: 22.r,
                                  height: 22.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? AppColors.darkScaffoldBackground
                                          : Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Send Reset Link',
                                  style: AppTextStyles.bold(
                                    fontSize: 16.sp,
                                    color: isDark
                                        ? AppColors.darkScaffoldBackground
                                        : Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Back to Login Link
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remembered your password? ',
                          style: AppTextStyles.regular(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.backToLogin,
                          child: Text(
                            'Log In',
                            style: AppTextStyles.bold(
                              fontSize: 14.sp,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
