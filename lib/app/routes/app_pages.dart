import 'package:get/get.dart';
import 'package:task_manager/app/modules/Login/login_controller.dart';
import 'package:task_manager/app/modules/Login/login_view.dart';
import 'package:task_manager/app/modules/dashboard/dashboard_controller.dart';
import 'package:task_manager/app/modules/dashboard/dashboard_view.dart';
import 'package:task_manager/app/modules/forgot_password/forgot_password_controller.dart';
import 'package:task_manager/app/modules/forgot_password/forgot_password_view.dart';
import 'package:task_manager/app/modules/home/home_controller.dart';
import 'package:task_manager/app/modules/home/home_view.dart';
import 'package:task_manager/app/modules/profile/profile_controller.dart';
import 'package:task_manager/app/modules/profile/profile_view.dart';
import 'package:task_manager/app/modules/signup/signup_controller.dart';
import 'package:task_manager/app/modules/signup/signup_view.dart';
import 'package:task_manager/app/modules/splash/splash_controller.dart';
import 'package:task_manager/app/modules/splash/splash_view.dart';
import 'package:task_manager/app/modules/statistics/statistics_controller.dart';
import 'package:task_manager/app/modules/statistics/statistics_view.dart';

class AppPage {
  AppPage._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController(), fenix: true);
        Get.lazyPut(() => HomeController(), fenix: true);
        Get.lazyPut(() => ProfileController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => const SignupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SignupController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ForgotPasswordController(), fenix: true);
      }),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController(), fenix: true);
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.STATISTICS,
      page: () => const StatisticsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StatisticsController(), fenix: true);
      }),
      transition: Transition.cupertino,
    ),
  ];
}

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const SIGNUP = _Paths.SIGNUP;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const PROFILE = _Paths.PROFILE;
  static const STATISTICS = _Paths.STATISTICS;
}

abstract class _Paths {
  _Paths._();

  static const String SPLASH = '/splash';
  static const String DASHBOARD = '/dashboard';
  static const String HOME = '/home';
  static const String LOGIN = '/login';
  static const String SIGNUP = '/signup';
  static const String FORGOT_PASSWORD = '/forgot-password';
  static const String PROFILE = '/profile';
  static const String STATISTICS = '/statistics';
}
