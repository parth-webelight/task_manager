import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'package:task_manager/app/services/auth_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/app/modules/signup/email_verification_view.dart';

import 'package:task_manager/app/services/network_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (!NetworkService.checkOnlineOrShowAlert()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final alerts = Get.find<AlertMessageUtils>();

    if (email.isEmpty || !AuthService.isValidStrictEmail(email)) {
      alerts.showErrorSnackBar(
        title: 'Invalid Email Address',
        message: 'Email must be a valid @gmail.com address (e.g. user@gmail.com)',
      );
      return;
    }

    if (password.isEmpty) {
      alerts.showErrorSnackBar(
        title: 'Password Required',
        message: 'Please enter your password',
      );
      return;
    }

    isLoading.value = true;

    try {
      // Firebase Login Operation (Checks email verification)
      await AuthService.loginWithEmailPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;

      alerts.showSuccessSnackBar(
        title: 'Welcome Back!',
        message: 'Logged in successfully',
      );

      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      isLoading.value = false;

      if (e is FirebaseAuthException && e.code == 'email-not-verified') {
        alerts.showErrorSnackBar(
          title: 'Email Not Verified',
          message: 'Please check your email inbox and verify your account first.',
        );
        // Redirect user to Email Verification View so they can resend link or verify
        EmailVerificationView.open(email: email, name: '');
        return;
      }

      final errorMessage = AuthService.getReadableErrorMessage(e);
      alerts.showErrorSnackBar(
        title: 'Login Failed',
        message: errorMessage,
      );
    }
  }

  void goToSignup() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offNamed(Routes.SIGNUP);
  }

  void handleForgotPassword() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  @override
  void onClose() {
    emailController.clear();
    passwordController.clear();
    super.onClose();
  }
}
