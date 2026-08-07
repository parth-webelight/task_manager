import 'package:get/get.dart';

class DashboardController extends GetxController {
  final selectedTabIndex = 0.obs;

  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
  }
}