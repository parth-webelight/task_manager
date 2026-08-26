import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/core/themes/theme_controller.dart';
import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/core/utils/session_manager.dart';
import 'package:task_manager/app/core/widgets/common_dialog.dart';
import 'package:task_manager/app/models/task_model.dart';
import 'package:task_manager/app/routes/app_pages.dart';
import 'package:task_manager/app/services/auth_service.dart';
import 'package:task_manager/app/services/category_service.dart';
import 'package:task_manager/app/services/notification_service.dart';
import 'package:task_manager/app/services/task_service.dart';

class HomeController extends GetxController {
  final selectedTabIndex = 0.obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final isProgressOverviewVisible = false.obs;

  void toggleProgressOverview() {
    isProgressOverviewVisible.value = !isProgressOverviewVisible.value;
  }

  final userName = 'Task Master'.obs;
  final userEmail = 'user@taskmanager.com'.obs;

  final categories = <String>['All'].obs;

  final userTasks = <TaskModel>[].obs;
  final isLoadingTasks = true.obs;
  final isLoadingCategories = true.obs;

  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  StreamSubscription<List<String>>? _categoriesSubscription;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().requestPermissions();
    });
    _loadUserData();
    _initTasksStream();
    _initCategoriesStream();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = AuthService.currentUser;
    if (firebaseUser != null) {
      if (firebaseUser.displayName != null &&
          firebaseUser.displayName!.isNotEmpty) {
        userName.value = firebaseUser.displayName!;
      }
      if (firebaseUser.email != null && firebaseUser.email!.isNotEmpty) {
        userEmail.value = firebaseUser.email!;
      }
    }

    final session = SessionManager();
    final name = await session.getStringValue(SessionManager.userName);
    final email = await session.getStringValue(SessionManager.userEmail);

    if (name.isNotEmpty) userName.value = name;
    if (email.isNotEmpty) userEmail.value = email;
  }

  void _initTasksStream() async {
    final firebaseUser = AuthService.currentUser;
    String userId = firebaseUser?.uid ?? '';

    if (userId.isEmpty) {
      userId = await SessionManager().getUserID();
    }

    if (userId.isEmpty) {
      userId = 'guest_user';
    }

    isLoadingTasks.value = true;
    _tasksSubscription?.cancel();
    _tasksSubscription = TaskService.streamUserTasks(userId).listen(
      (taskList) {
        userTasks.assignAll(taskList);
        isLoadingTasks.value = false;
        for (final task in taskList) {
          if (!task.isCompleted) {
            NotificationService().scheduleTaskNotifications(task);
          }
        }
      },
      onError: (error) {
        debugPrint('Error streaming tasks: $error');
        isLoadingTasks.value = false;
      },
    );
  }

  void _initCategoriesStream() async {
    final firebaseUser = AuthService.currentUser;
    String userId = firebaseUser?.uid ?? '';

    if (userId.isEmpty) {
      userId = await SessionManager().getUserID();
    }

    if (userId.isNotEmpty) {
      isLoadingCategories.value = true;
      await CategoryService.initializeDefaultCategoriesIfEmpty(userId);
      _categoriesSubscription?.cancel();
      _categoriesSubscription = CategoryService.streamUserCategories(userId)
          .listen(
            (catList) {
              final updatedList = ['All', ...catList];
              categories.assignAll(updatedList);
              isLoadingCategories.value = false;
            },
            onError: (error) {
              debugPrint('Error streaming categories: $error');
              isLoadingCategories.value = false;
            },
          );
    } else {
      isLoadingCategories.value = false;
    }
  }

  Future<void> addCustomCategory(String categoryName) async {
    final cleanName = categoryName.trim();
    if (cleanName.isEmpty) return;

    final firebaseUser = AuthService.currentUser;
    String userId = firebaseUser?.uid ?? '';
    if (userId.isEmpty) {
      userId = await SessionManager().getUserID();
    }

    final alerts = Get.find<AlertMessageUtils>();

    try {
      // Optimistically insert new category at index 1 (right after 'All') so it appears first in lists
      final currentCats = List<String>.from(categories);
      currentCats.removeWhere((c) => c.toLowerCase() == cleanName.toLowerCase());
      if (currentCats.isNotEmpty && currentCats.first == 'All') {
        currentCats.insert(1, cleanName);
      } else {
        currentCats.insert(0, cleanName);
      }
      categories.assignAll(currentCats);

      await CategoryService.addCustomCategory(userId, cleanName);
      alerts.showSuccessSnackBar(
        title: 'Category Added',
        message: 'Custom category "$cleanName" created.',
      );
    } catch (e) {
      alerts.showErrorSnackBar(
        title: 'Error',
        message: 'Could not add category: $e',
      );
    }
  }

  Future<void> deleteCustomCategory(String categoryName) async {
    final cleanName = categoryName.trim();
    if (cleanName.isEmpty) return;

    if (cleanName.toLowerCase() == 'all') {
      Get.find<AlertMessageUtils>().showErrorSnackBar(
        title: 'Action Restricted',
        message: '"All" filter cannot be deleted.',
      );
      return;
    }

    final firebaseUser = AuthService.currentUser;
    String userId = firebaseUser?.uid ?? '';
    if (userId.isEmpty) {
      userId = await SessionManager().getUserID();
    }

    final alerts = Get.find<AlertMessageUtils>();

    try {
      categories.removeWhere((c) => c.toLowerCase() == cleanName.toLowerCase());
      if (selectedCategory.value.toLowerCase() == cleanName.toLowerCase()) {
        selectedCategory.value = categories.firstWhere((c) => c != 'All', orElse: () => 'All');
      }

      await CategoryService.deleteCategory(userId, cleanName);
      alerts.showSuccessSnackBar(
        title: 'Category Deleted',
        message: 'Category "$cleanName" deleted.',
      );
    } catch (e) {
      alerts.showErrorSnackBar(
        title: 'Error',
        message: 'Could not delete category: $e',
      );
    }
  }

  Future<void> deleteCategoryWithTasks(
    String categoryName,
    List<TaskModel> tasksToDelete,
  ) async {
    final cleanName = categoryName.trim();
    if (cleanName.isEmpty) return;

    final firebaseUser = AuthService.currentUser;
    String userId = firebaseUser?.uid ?? '';
    if (userId.isEmpty) {
      userId = await SessionManager().getUserID();
    }

    final alerts = Get.find<AlertMessageUtils>();

    try {
      for (final task in tasksToDelete) {
        await TaskService.deleteTask(userId, task.id);
        await NotificationService().cancelTaskNotifications(task.id);
      }

      userTasks.removeWhere(
        (t) => t.category.trim().toLowerCase() == cleanName.toLowerCase(),
      );

      categories.removeWhere((c) => c.toLowerCase() == cleanName.toLowerCase());
      if (selectedCategory.value.toLowerCase() == cleanName.toLowerCase()) {
        selectedCategory.value = categories.firstWhere((c) => c != 'All', orElse: () => 'All');
      }

      await CategoryService.deleteCategory(userId, cleanName);
      alerts.showSuccessSnackBar(
        title: 'Category & Tasks Deleted',
        message: 'Category "$cleanName" and ${tasksToDelete.length} associated task(s) deleted.',
      );
    } catch (e) {
      alerts.showErrorSnackBar(
        title: 'Error',
        message: 'Could not delete category and tasks: $e',
      );
    }
  }

  void confirmDeleteCategory(
    BuildContext context,
    String catName, {
    VoidCallback? onDeleted,
  }) {
    if (catName.toLowerCase() == 'all') {
      Get.find<AlertMessageUtils>().showCustomSnackBar(
        message: '"All" filter cannot be deleted.',
      );
      return;
    }

    CommonDialog.showConfirmDialog(
      title: 'Delete Category',
      message: 'Are you sure you want to delete "$catName"?',
      yesText: 'Delete',
      noText: 'Cancel',
      icon: Icons.delete_forever_rounded,
      iconColor: AppColors.priorityHigh,
      onYes: () async {
        final associatedTasks = userTasks.where(
          (t) => t.category.trim().toLowerCase() == catName.trim().toLowerCase(),
        ).toList();

        if (associatedTasks.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CommonDialog.showConfirmDialog(
              title: 'Delete Associated Tasks?',
              message:
                  'Deleting "$catName" will also delete its ${associatedTasks.length} task(s). Proceed?',
              yesText: 'Delete All',
              noText: 'Cancel',
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.priorityHigh,
              onYes: () async {
                await deleteCategoryWithTasks(catName, associatedTasks);
                onDeleted?.call();
              },
            );
          });
        } else {
          await deleteCustomCategory(catName);
          onDeleted?.call();
        }
      },
    );
  }

  void showAddCategoryDialog(BuildContext context, {Function(String)? onCategoryAdded}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'New Category',
          style: AppTextStyles.bold(
            fontSize: 18.sp,
            color: isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter custom category name (e.g. Finance, Projects, Hobbies):',
              style: AppTextStyles.regular(
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller,
              autofocus: true,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.darkPrimaryText
                    : AppColors.lightPrimaryText,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Freelance',
                hintStyle: AppTextStyles.regular(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkScaffoldBackground
                    : AppColors.lightScaffoldBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final catName = controller.text.trim();
              if (catName.isNotEmpty) {
                Get.back();
                await addCustomCategory(catName);
                onCategoryAdded?.call(catName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Add',
              style: AppTextStyles.bold(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  final categoryScrollController = ScrollController();

  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  void selectCategory(String category, [int index = 0]) {
    selectedCategory.value = category;

    if (categoryScrollController.hasClients && index >= 0) {
      const double itemEstimatedWidth = 85.0;
      double targetOffset = (index * itemEstimatedWidth) - 80.0;
      if (targetOffset < 0) targetOffset = 0;
      final maxScroll = categoryScrollController.position.maxScrollExtent;
      if (targetOffset > maxScroll) targetOffset = maxScroll;

      categoryScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final firebaseUser = AuthService.currentUser;
    String userId = firebaseUser?.uid ?? await SessionManager().getUserID();

    final newStatus = !task.isCompleted;
    final alerts = Get.find<AlertMessageUtils>();

    try {
      await TaskService.toggleTaskStatus(userId, task.id, newStatus);
      if (newStatus) {
        await NotificationService().cancelTaskNotifications(task.id);
      } else {
        await NotificationService().scheduleTaskNotifications(
          task.copyWith(isCompleted: false),
        );
      }
      alerts.showToastMessages(
        msg: newStatus ? 'Task completed!' : 'Task marked pending',
      );
    } catch (e) {
      alerts.showErrorSnackBar(
        title: 'Error',
        message: 'Could not update task status.',
      );
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final firebaseUser = AuthService.currentUser;
    String userId = firebaseUser?.uid ?? await SessionManager().getUserID();
    final alerts = Get.find<AlertMessageUtils>();

    try {
      await TaskService.deleteTask(userId, task.id);
      await NotificationService().cancelTaskNotifications(task.id);
      alerts.showSuccessSnackBar(
        title: 'Task Deleted',
        message: 'Task "${task.title}" has been deleted.',
      );
    } catch (e) {
      alerts.showErrorSnackBar(
        title: 'Error Deleting Task',
        message: e.toString(),
      );
    }
  }

  final isCompletedSectionExpanded = false.obs;

  void toggleCompletedSection() {
    isCompletedSectionExpanded.value = !isCompletedSectionExpanded.value;
  }

  List<TaskModel> get filteredTasks {
    return userTasks.where((task) {
      final matchesCategory =
          selectedCategory.value == 'All' ||
          task.category.toLowerCase() == selectedCategory.value.toLowerCase();

      final query = searchQuery.value.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<TaskModel> get pendingFilteredTasks =>
      filteredTasks.where((t) => !t.isCompleted).toList();

  List<TaskModel> get completedFilteredTasks =>
      filteredTasks.where((t) => t.isCompleted).toList();

  List<TaskModel> get tasks => userTasks;
  int get completedTasksCount => userTasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => userTasks.where((t) => !t.isCompleted).length;
  int get totalTasksCount => userTasks.length;

  double get completionPercentage {
    if (totalTasksCount == 0) return 0.0;
    return completedTasksCount / totalTasksCount;
  }

  /// Open App Theme Selection Bottom Sheet
  void showThemeSelectionBottomSheet() {
    final themeController = Get.find<ThemeController>();
    final isDark = Get.isDarkMode;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  'App Theme',
                  style: AppTextStyles.bold(
                    fontSize: 18.sp,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Choose your preferred appearance mode',
                  style: AppTextStyles.regular(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
                SizedBox(height: 20.h),

                // 1. Light Mode Option
                Obx(
                  () => _buildThemeTile(
                    title: 'Light Mode',
                    subtitle: 'Always use clean light theme',
                    icon: Icons.light_mode_rounded,
                    mode: ThemeMode.light,
                    currentMode: themeController.themeMode,
                    isDark: isDark,
                    onTap: () {
                      themeController.setThemeMode(ThemeMode.light);
                      Get.back();
                    },
                  ),
                ),

                SizedBox(height: 10.h),

                // 2. Dark Mode Option
                Obx(
                  () => _buildThemeTile(
                    title: 'Dark Mode',
                    subtitle: 'Always use sleek dark theme',
                    icon: Icons.dark_mode_rounded,
                    mode: ThemeMode.dark,
                    currentMode: themeController.themeMode,
                    isDark: isDark,
                    onTap: () {
                      themeController.setThemeMode(ThemeMode.dark);
                      Get.back();
                    },
                  ),
                ),

                SizedBox(height: 10.h),

                // 3. System Default Option
                Obx(
                  () => _buildThemeTile(
                    title: 'System Default',
                    subtitle: 'Match system device settings automatically',
                    icon: Icons.settings_brightness_rounded,
                    mode: ThemeMode.system,
                    currentMode: themeController.themeMode,
                    isDark: isDark,
                    onTap: () {
                      themeController.setThemeMode(ThemeMode.system);
                      Get.back();
                    },
                  ),
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildThemeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = currentMode == mode;
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withAlpha(25)
              : (isDark
                    ? AppColors.darkScaffoldBackground
                    : AppColors.lightScaffoldBackground),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor
                    : (isDark
                          ? AppColors.darkCardBackground
                          : AppColors.lightCardBackground),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText),
                size: 20.r,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bold(
                      fontSize: 15.sp,
                      color: isSelected
                          ? activeColor
                          : (isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.regular(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: activeColor, size: 22.r),
          ],
        ),
      ),
    );
  }

  void confirmLogout() {
    CommonDialog.showLogoutDialog(
      onLogout: () async {
        await AuthService.signOut();
        Get.find<AlertMessageUtils>().showCustomSnackBar(
          message: 'Logged out successfully',
        );
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    _categoriesSubscription?.cancel();
    categoryScrollController.dispose();
    super.onClose();
  }
}
