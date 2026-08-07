import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/core/utils/image_constant.dart';
import 'package:task_manager/app/core/widgets/custom_fillable_text_field.dart';
import 'package:task_manager/app/modules/Login/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),

                  // Animated App Logo
                  ZoomIn(
                    duration: const Duration(milliseconds: 700),
                    child: Center(
                      child: Container(
                        width: 96.r,
                        height: 96.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightPrimary.withAlpha(
                                isDark ? 80 : 50,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          icSplashLogo,
                          width: 96.r,
                          height: 96.r,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Welcome Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold(
                        fontSize: 26.sp,
                        color: isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                      ),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 600),
                    child: Text(
                      'Sign in to continue managing your tasks',
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

                  // 1. Email Address Field (Using CustomFillableTextField)
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
                          hint: 'Enter your email address',
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          fillColor: fillColor,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 2. Password Field (Using CustomFillableTextField)
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: AppTextStyles.medium(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => CustomFillableTextField(
                            controller: controller.passwordController,
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            fillColor: fillColor,
                            obscureText: !controller.isPasswordVisible.value,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                                size: 20.r,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Forgot Password Link
                  FadeInUp(
                    delay: const Duration(milliseconds: 450),
                    duration: const Duration(milliseconds: 600),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.handleForgotPassword,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.h,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.semiBold(
                            fontSize: 13.sp,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Log In Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 600),
                    child: Obx(
                      () => SizedBox(
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.login,
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
                                  'Log In',
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

                  SizedBox(height: 28.h),

                  // Register Account Navigation Link
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.regular(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.goToSignup,
                          child: Text(
                            'Sign Up',
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

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
