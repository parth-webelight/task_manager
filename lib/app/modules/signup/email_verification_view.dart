import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/core/utils/session_manager.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'package:task_manager/app/services/auth_service.dart';

class EmailVerificationView extends StatefulWidget {
  final String email;
  final String name;

  const EmailVerificationView({
    super.key,
    required this.email,
    required this.name,
  });

  static void open({required String email, required String name}) {
    Get.to(
      () => EmailVerificationView(email: email, name: name),
      transition: Transition.rightToLeftWithFade,
    );
  }

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check status every 4 seconds in background
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _checkVerificationStatus(isAuto: true);
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkVerificationStatus({bool isAuto = false}) async {
    if (_isChecking) return;

    if (!isAuto) {
      setState(() => _isChecking = true);
    }

    try {
      final isVerified = await AuthService.checkEmailVerifiedStatus();

      if (isVerified) {
        _autoCheckTimer?.cancel();

        final user = AuthService.currentUser;
        if (user != null) {
          final session = SessionManager();
          await session.setBoolValue(SessionManager.isLogin, true);
          await session.setStringValue(SessionManager.userID, user.uid);
          await session.setStringValue(
            SessionManager.userName,
            widget.name.isNotEmpty
                ? widget.name
                : (user.displayName ?? widget.email.split('@').first),
          );
          await session.setStringValue(SessionManager.userEmail, widget.email);
        }

        Get.find<AlertMessageUtils>().showSuccessSnackBar(
          title: 'Email Verified!',
          message: 'Your account has been verified successfully. Welcome!',
        );

        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        if (!isAuto) {
          setState(() => _isChecking = false);
          Get.find<AlertMessageUtils>().showErrorSnackBar(
            title: 'Not Verified Yet',
            message:
                'Email link is not clicked yet. Please check your inbox (or Spam folder).',
          );
        }
      }
    } catch (e) {
      if (!isAuto) {
        setState(() => _isChecking = false);
        Get.find<AlertMessageUtils>().showErrorSnackBar(
          title: 'Verification Check Failed',
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      await AuthService.sendEmailVerification();
      setState(() => _isResending = false);
      _startCooldownTimer();

      Get.find<AlertMessageUtils>().showSuccessSnackBar(
        title: 'Verification Link Sent',
        message: 'A new verification link was sent to ${widget.email}',
      );
    } catch (e) {
      setState(() => _isResending = false);
      Get.find<AlertMessageUtils>().showErrorSnackBar(
        title: 'Failed to Resend Email',
        message: AuthService.getReadableErrorMessage(e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkScaffoldBackground
          : AppColors.lightScaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
          ),
          onPressed: () async {
            await AuthService.signOut();
            Get.offAllNamed(Routes.LOGIN);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Envelope Icon
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkPrimary, AppColors.darkSecondary]
                            : [
                                AppColors.lightPrimary,
                                AppColors.lightSecondary,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha(80),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      size: 52.r,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Title
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Verify Your Email',
                    style: AppTextStyles.bold(
                      fontSize: 24.sp,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.lightPrimaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 10.h),

                // Subtitle with Email highlight box
                FadeInDown(
                  delay: const Duration(milliseconds: 250),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'We sent a verification link to:',
                          style: AppTextStyles.regular(
                            fontSize: 13.sp,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.email,
                          style: AppTextStyles.bold(
                            fontSize: 15.sp,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Important Note: Spam Folder Warning
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.amber.shade900.withAlpha(50)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.amber.shade700.withAlpha(120),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber.shade700,
                          size: 22.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Important Note: If you do not see the email in your Inbox, please check your SPAM / Junk folder!',
                            style: AppTextStyles.bold(
                              fontSize: 12.sp,
                              color: isDark
                                  ? Colors.amber.shade200
                                  : Colors.amber.shade900,
                            ).copyWith(height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // 1. Check Status Button
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  duration: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _isChecking
                          ? null
                          : () => _checkVerificationStatus(isAuto: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 4,
                      ),
                      child: _isChecking
                          ? SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'I Have Verified Link',
                                  style: AppTextStyles.bold(
                                    fontSize: 15.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // 2. Resend Verification Button
                FadeInUp(
                  delay: const Duration(milliseconds: 550),
                  duration: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: (_resendCooldown > 0 || _isResending)
                          ? null
                          : _resendVerificationEmail,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _resendCooldown > 0
                              ? Colors.grey
                              : primaryColor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isResending
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            )
                          : Text(
                              _resendCooldown > 0
                                  ? 'Resend Email in ${_resendCooldown}s'
                                  : 'Resend Verification Email',
                              style: AppTextStyles.bold(
                                fontSize: 14.sp,
                                color: _resendCooldown > 0
                                    ? Colors.grey
                                    : (isDark
                                          ? AppColors.darkPrimaryText
                                          : AppColors.lightPrimaryText),
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // 3. Back to Login Text Button
                FadeInUp(
                  delay: const Duration(milliseconds: 650),
                  duration: const Duration(milliseconds: 600),
                  child: TextButton.icon(
                    onPressed: () async {
                      await AuthService.signOut();
                      Get.offAllNamed(Routes.LOGIN);
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: 16.r,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                    label: Text(
                      'Back to Login Screen',
                      style: AppTextStyles.medium(
                        fontSize: 13.5.sp,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
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
}
