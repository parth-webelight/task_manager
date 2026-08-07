import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/utils/session_manager.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'package:task_manager/app/services/auth_service.dart';
import 'package:task_manager/app/services/notification_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermissions();
    });
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    bool isSessionLoggedIn = await SessionManager().isLoggedIn();
    bool isFirebaseLoggedIn = AuthService.isUserLoggedIn;
    bool isEmailVerified = AuthService.currentUser?.emailVerified ?? false;

    if ((isSessionLoggedIn || isFirebaseLoggedIn) && isEmailVerified) {
      debugPrint("Firebase/Session User Active & Verified -> Syncing Language & Navigating to Dashboard");
      await AuthService.syncUserLanguageFromFirestore();
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      debugPrint("User not logged in or email unverified -> Navigating to Login Screen");
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
