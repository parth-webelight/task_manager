import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/localizations/language.dart';
import 'package:task_manager/app/models/task_model.dart';
import 'package:task_manager/app/modules/home/home_controller.dart';
import 'package:task_manager/app/modules/home/widgets/add_task_bottom_sheet.dart';
import 'package:task_manager/app/routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final lang = Languages.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: isDark
              ? AppColors.darkScaffoldBackground
              : AppColors.lightScaffoldBackground,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final topEstimatedHeight =
                    controller.isProgressOverviewVisible.value ? 360.h : 230.h;
                final emptyStateHeight =
                    (constraints.maxHeight - topEstimatedHeight).clamp(
                      260.0,
                      1000.0,
                    );

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Greeting Header
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(
                                    () => Text(
                                      '${lang?.hello ?? 'Hello'}, ${controller.userName.value}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bold(
                                        fontSize: 22.sp,
                                        color: isDark
                                            ? AppColors.darkPrimaryText
                                            : AppColors.lightPrimaryText,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Obx(
                                    () => Text(
                                      '${controller.pendingTasksCount} ${lang?.pendingTasksMsg ?? 'pending tasks'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.regular(
                                        fontSize: 13.sp,
                                        color: isDark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.lightSecondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            // Action Buttons Header (Statistics + Progress Toggle)
                            Row(
                              children: [
                                // Full Statistics Screen Button
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.STATISTICS);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color:
                                          (isDark
                                                  ? AppColors.darkPrimary
                                                  : AppColors.lightPrimary)
                                              .withAlpha(30),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.bar_chart_rounded,
                                      color: isDark
                                          ? AppColors.darkPrimary
                                          : AppColors.lightPrimary,
                                      size: 22.r,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),

                                // Quick Progress Overview Toggle Button
                                Obx(() {
                                  final isVisible = controller
                                      .isProgressOverviewVisible
                                      .value;
                                  final primaryColor = isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary;

                                  return GestureDetector(
                                    onTap: controller.toggleProgressOverview,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      padding: EdgeInsets.all(10.r),
                                      decoration: BoxDecoration(
                                        color: isVisible
                                            ? primaryColor
                                            : primaryColor.withAlpha(30),
                                        shape: BoxShape.circle,
                                        boxShadow: isVisible
                                            ? [
                                                BoxShadow(
                                                  color: primaryColor.withAlpha(
                                                    100,
                                                  ),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Icon(
                                        Icons.analytics_rounded,
                                        color: isVisible
                                            ? Colors.white
                                            : primaryColor,
                                        size: 22.r,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 14.h),

                      // Collapsible Progress Overview Card
                      Obx(() {
                        final isVisible =
                            controller.isProgressOverviewVisible.value;

                        return AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          child: isVisible
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 18.h),
                                  child: Container(
                                    padding: EdgeInsets.all(18.r),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                AppColors.darkPrimary,
                                                AppColors.darkSecondary,
                                              ]
                                            : [
                                                AppColors.lightPrimary,
                                                AppColors.lightSecondary,
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (isDark
                                                      ? AppColors.darkPrimary
                                                      : AppColors.lightPrimary)
                                                  .withAlpha(80),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              lang?.dailyCompletion ??
                                                  'Daily Completion',
                                              style: AppTextStyles.bold(
                                                fontSize: 16.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Obx(
                                              () => Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withAlpha(
                                                    50,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                ),
                                                child: Text(
                                                  '${controller.completedTasksCount}/${controller.totalTasksCount} ${lang?.doneTasks ?? 'Done'}',
                                                  style: AppTextStyles.semiBold(
                                                    fontSize: 12.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 14.h),
                                        Obx(() {
                                          final progress =
                                              controller.completionPercentage;
                                          final percentageText =
                                              (progress * 100).toInt();

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  minHeight: 8.h,
                                                  backgroundColor: Colors.white
                                                      .withAlpha(60),
                                                  valueColor:
                                                      const AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              ),
                                              SizedBox(height: 10.h),
                                              Text(
                                                '$percentageText% ${lang?.completedOfTotal ?? 'completed of total tasks'}',
                                                style: AppTextStyles.regular(
                                                  fontSize: 12.sp,
                                                  color: Colors.white.withAlpha(
                                                    220,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      }),

                      // Search Bar Field
                      FadeInUp(
                        delay: const Duration(milliseconds: 50),
                        duration: const Duration(milliseconds: 200),
                        child: TextField(
                          onChanged: controller.updateSearchQuery,
                          enableSuggestions: false,
                          autocorrect: false,
                          enableIMEPersonalizedLearning: false,
                          style: AppTextStyles.medium(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                lang?.searchHint ??
                                'Search tasks by title or note...',
                            hintStyle: AppTextStyles.regular(
                              fontSize: 13.sp,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              size: 20.r,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                            ),
                            filled: true,
                            fillColor: cardBg,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 16.w,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15.h),

                      // Combined Loading & Content View
                      Obx(() {
                        final isLoading =
                            controller.isLoadingTasks.value ||
                            controller.isLoadingCategories.value;
                        final pendingList = controller.pendingFilteredTasks;
                        final completedList = controller.completedFilteredTasks;
                        final isAllEmpty =
                            pendingList.isEmpty && completedList.isEmpty;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Categories Horizontal Chips Selector
                            FadeInUp(
                              delay: const Duration(milliseconds: 50),
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                height: 38.h,
                                child: Obx(
                                  () => ListView.separated(
                                    controller:
                                        controller.categoryScrollController,
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: controller.categories.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(width: 10.w),
                                    itemBuilder: (context, index) {
                                      final cat = controller.categories[index];
                                      return Obx(() {
                                        final isSelected =
                                            controller.selectedCategory.value ==
                                            cat;
                                        return GestureDetector(
                                          onTap: () => controller
                                              .selectCategory(cat, index),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 8.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (isDark
                                                        ? AppColors.darkPrimary
                                                        : AppColors
                                                              .lightPrimary)
                                                  : cardBg,
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.transparent
                                                    : (isDark
                                                          ? AppColors.darkBorder
                                                          : AppColors
                                                                .lightBorder),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                lang?.getCategoryName(cat) ??
                                                    cat,
                                                style: isSelected
                                                    ? AppTextStyles.semiBold(
                                                        fontSize: 13.sp,
                                                        color: Colors.white,
                                                      )
                                                    : AppTextStyles.regular(
                                                        fontSize: 13.sp,
                                                        color: isDark
                                                            ? AppColors
                                                                  .darkSecondaryText
                                                            : AppColors
                                                                  .lightSecondaryText,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Task List Items, Loader, or Empty State
                            isLoading
                                ? SizedBox(
                                    height: emptyStateHeight,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: isDark
                                            ? AppColors.darkPrimary
                                            : AppColors.lightPrimary,
                                      ),
                                    ),
                                  )
                                : isAllEmpty
                                ? SizedBox(
                                    height: emptyStateHeight,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.task_rounded,
                                            size: 52.r,
                                            color:
                                                (isDark
                                                        ? AppColors
                                                              .darkSecondaryText
                                                        : AppColors
                                                              .lightSecondaryText)
                                                    .withAlpha(180),
                                          ),
                                          SizedBox(height: 14.h),
                                          Text(
                                            lang?.noTasksFound ??
                                                'No tasks found',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.bold(
                                              fontSize: 15.sp,
                                              color: isDark
                                                  ? AppColors.darkSecondaryText
                                                  : AppColors
                                                        .lightSecondaryText,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            lang?.tapToCreateTask ??
                                                'Tap "+ Add Task" button to create a new task.',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.regular(
                                              fontSize: 12.5.sp,
                                              color:
                                                  (isDark
                                                          ? AppColors
                                                                .darkSecondaryText
                                                          : AppColors
                                                                .lightSecondaryText)
                                                      .withAlpha(200),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 1. Active / Pending Tasks List
                                      if (pendingList.isNotEmpty)
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: pendingList.length,
                                          separatorBuilder: (context, index) =>
                                              SizedBox(height: 12.h),
                                          itemBuilder: (context, index) =>
                                              _buildTaskTile(
                                                context,
                                                pendingList[index],
                                                isDark,
                                                cardBg,
                                                index,
                                              ),
                                        ),

                                      // 2. Collapsible Completed Tasks Section
                                      if (completedList.isNotEmpty) ...[
                                        if (pendingList.isNotEmpty)
                                          SizedBox(height: 20.h),

                                        Obx(() {
                                          final isExpanded = controller
                                              .isCompletedSectionExpanded
                                              .value;

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FadeInUp(
                                                delay: Duration(
                                                  milliseconds:
                                                      30 +
                                                      (pendingList.length * 20),
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                child: InkWell(
                                                  onTap: controller
                                                      .toggleCompletedSection,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        14.r,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 16.w,
                                                          vertical: 12.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: cardBg,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14.r,
                                                          ),
                                                      border: Border.all(
                                                        color: isDark
                                                            ? AppColors
                                                                  .darkBorder
                                                            : AppColors
                                                                  .lightBorder,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .check_circle_outline_rounded,
                                                              color: AppColors
                                                                  .statusCompleted,
                                                              size: 20.r,
                                                            ),
                                                            SizedBox(
                                                              width: 8.w,
                                                            ),
                                                            Text(
                                                              '${lang?.completedTasksSection ?? 'Completed'} (${completedList.length})',
                                                              style: AppTextStyles.bold(
                                                                fontSize: 14.sp,
                                                                color: isDark
                                                                    ? AppColors
                                                                          .darkPrimaryText
                                                                    : AppColors
                                                                          .lightPrimaryText,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Icon(
                                                          isExpanded
                                                              ? Icons
                                                                    .keyboard_arrow_up_rounded
                                                              : Icons
                                                                    .keyboard_arrow_down_rounded,
                                                          size: 22.r,
                                                          color: isDark
                                                              ? AppColors
                                                                    .darkSecondaryText
                                                              : AppColors
                                                                    .lightSecondaryText,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (isExpanded) ...[
                                                SizedBox(height: 12.h),
                                                ListView.separated(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      completedList.length,
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          SizedBox(
                                                            height: 12.h,
                                                          ),
                                                  itemBuilder:
                                                      (
                                                        context,
                                                        index,
                                                      ) => _buildTaskTile(
                                                        context,
                                                        completedList[index],
                                                        isDark,
                                                        cardBg,
                                                        index,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                          ],
                        );
                      }),

                      SizedBox(height: 80.h),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    TaskModel task,
    bool isDark,
    Color cardBg,
    int index,
  ) {
    final lang = Languages.of(context);
    final priorityColor = AppColors.getPriorityColor(task.priority);
    final categoryColor = AppColors.getCategoryColor(task.category);

    return FadeInUp(
      delay: Duration(milliseconds: 30 + (index * 20)),
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey.shade300).withAlpha(
                30,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox Button
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: GestureDetector(
                onTap: () => controller.toggleTaskCompletion(task),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? AppColors.statusCompleted
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.statusCompleted
                          : (isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText),
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          size: 15.r,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),

            SizedBox(width: 10.w),

            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: task.isCompleted
                        ? AppTextStyles.regular(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ).copyWith(decoration: TextDecoration.lineThrough)
                        : AppTextStyles.semiBold(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText,
                          ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular(
                        fontSize: 11.5.sp,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  // Responsive Wrap
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 4.h,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category Pill
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              lang?.getCategoryName(task.category) ??
                                  task.category,
                              style: AppTextStyles.medium(
                                fontSize: 10.5.sp,
                                color: categoryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),

                          // Priority Pill
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              lang?.getPriorityName(task.priority) ??
                                  task.priority,
                              style: AppTextStyles.medium(
                                fontSize: 10.5.sp,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Full Due Date & Time
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12.r,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            DateFormat(
                              'MMM dd, h:mm a',
                              Get.locale?.languageCode ?? 'en',
                            ).format(task.dueDate),
                            style: AppTextStyles.medium(
                              fontSize: 10.5.sp,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 4.w),

            // More Options Popup Menu (Edit & Delete)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.more_vert_rounded,
                size: 18.r,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              color: cardBg,
              onSelected: (value) {
                if (value == 'edit') {
                  AddTaskBottomSheet.show(context, taskToEdit: task);
                } else if (value == 'delete') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showDeleteConfirmationDialog(context, task);
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16.r,
                        color: isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        lang?.editTask ?? 'Edit Task',
                        style: AppTextStyles.medium(
                          fontSize: 13.sp,
                          color: isDark
                              ? AppColors.darkPrimaryText
                              : AppColors.lightPrimaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 16.r,
                        color: AppColors.priorityHigh,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        lang?.deleteTask ?? 'Delete Task',
                        style: AppTextStyles.medium(
                          fontSize: 13.sp,
                          color: AppColors.priorityHigh,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, TaskModel task) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Task?',
          style: AppTextStyles.bold(
            fontSize: 18.sp,
            color: isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          style: AppTextStyles.regular(
            fontSize: 14.sp,
            color: isDark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.deleteTask(task);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.priorityHigh,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTextStyles.bold(fontSize: 14.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
