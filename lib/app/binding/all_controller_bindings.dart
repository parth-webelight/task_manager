import 'package:get/get.dart';
import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/modules/Login/login_controller.dart';
import 'package:task_manager/app/modules/dashboard/dashboard_controller.dart';
import 'package:task_manager/app/modules/forgot_password/forgot_password_controller.dart';
import 'package:task_manager/app/modules/home/home_controller.dart';
import 'package:task_manager/app/modules/profile/profile_controller.dart';
import 'package:task_manager/app/modules/signup/signup_controller.dart';
import 'package:task_manager/app/modules/splash/splash_controller.dart';

class AllControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AlertMessageUtils>(AlertMessageUtils(), permanent: true);
    Get.put<SplashController>(SplashController());
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<SignupController>(() => SignupController(), fenix: true);
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController(), fenix: true);
  }
}
