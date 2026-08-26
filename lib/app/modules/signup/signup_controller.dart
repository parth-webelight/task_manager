import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'package:task_manager/app/services/auth_service.dart';

import 'package:task_manager/app/modules/signup/email_verification_view.dart';

import 'package:task_manager/app/services/network_service.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signup() async {
    if (!NetworkService.checkOnlineOrShowAlert()) {
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final alerts = Get.find<AlertMessageUtils>();

    if (name.isEmpty) {
      alerts.showErrorSnackBar(
        title: 'Required Field',
        message: 'Please enter your full name',
      );
      return;
    }

    if (name.length < 2) {
      alerts.showErrorSnackBar(
        title: 'Invalid Name',
        message: 'Full Name must be at least 2 characters long',
      );
      return;
    }

    if (name.length > 40) {
      alerts.showErrorSnackBar(
        title: 'Name Too Long',
        message: 'Full Name cannot exceed 40 characters',
      );
      return;
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(name)) {
      alerts.showErrorSnackBar(
        title: 'Invalid Name Format',
        message: 'Full Name should only contain alphabets and spaces',
      );
      return;
    }

    if (email.isEmpty || !AuthService.isValidStrictEmail(email)) {
      alerts.showErrorSnackBar(
        title: 'Invalid Email Address',
        message:
            'Email must be a valid @gmail.com address (e.g. user@gmail.com)',
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      alerts.showErrorSnackBar(
        title: 'Weak Password',
        message: 'Password must be at least 6 characters long',
      );
      return;
    }

    isLoading.value = true;

    try {
      // Real Firebase Signup Operation (sends verification email)
      await AuthService.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );

      isLoading.value = false;

      alerts.showSuccessSnackBar(
        title: 'Verification Email Sent',
        message: 'Please verify your email inbox to activate your account!',
      );

      // Navigate to Email Verification Waiting Screen
      EmailVerificationView.open(email: email, name: name);
    } catch (e) {
      isLoading.value = false;
      final errorMessage = AuthService.getReadableErrorMessage(e);
      alerts.showErrorSnackBar(
        title: 'Registration Failed',
        message: errorMessage,
      );
    }
  }

  void goToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();
    Get.offNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    super.onClose();
  }
}
