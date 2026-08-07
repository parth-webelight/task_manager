import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'package:task_manager/app/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();
    final alerts = Get.find<AlertMessageUtils>();

    if (email.isEmpty || !AuthService.isValidStrictEmail(email)) {
      alerts.showErrorSnackBar(
        title: 'Invalid Gmail Address',
        message: 'Please enter a valid @gmail.com address (e.g. user@gmail.com)',
      );
      return;
    }

    isLoading.value = true;

    try {
      await AuthService.sendPasswordResetEmail(email);
      isLoading.value = false;

      alerts.showSuccessSnackBar(
        title: 'Reset Link Sent',
        message: 'Password reset link sent to $email. Please check your Inbox (or Spam folder).',
      );

      // Return to Login Screen after a short delay
      await Future.delayed(const Duration(milliseconds: 1800));
      Get.offNamed(Routes.LOGIN);
    } catch (e) {
      isLoading.value = false;
      final errorMessage = AuthService.getReadableErrorMessage(e);
      alerts.showErrorSnackBar(
        title: 'Reset Failed',
        message: errorMessage,
      );
    }
  }

  void backToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.back();
  }

  @override
  void onClose() {
    emailController.clear();
    super.onClose();
  }
}
