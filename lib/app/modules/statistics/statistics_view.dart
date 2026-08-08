import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/localizations/language.dart';
import 'package:task_manager/app/modules/statistics/statistics_controller.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({super.key});

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
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
            size: 20.r,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Task Analytics & Stats',
          style: AppTextStyles.bold(
            fontSize: 18.sp,
            color: isDark
                ? AppColors.darkPrimaryText
                : AppColors.lightPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: Summary KPI Grid
              _buildSummaryKpiGrid(
                context,
                isDark,
                cardBg,
                primaryColor,
              ),

              SizedBox(height: 22.h),

              // ⭕ SECTION 2: Task Status Overview (Completion Rate Donut Chart)
              _buildCompletionPieChartCard(
                context,
                isDark,
                cardBg,
                primaryColor,
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. KPI Summary Cards Grid
  Widget _buildSummaryKpiGrid(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color primaryColor,
  ) {
    final lang = Languages.of(context);

    return Obx(() {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 1.35,
        children: [
          // Total Tasks
          _buildKpiCard(
            title: lang?.totalTasks ?? 'Total Tasks',
            value: controller.totalTasksCount.toString(),
            icon: Icons.task_alt_rounded,
            color: primaryColor,
            isDark: isDark,
            cardBg: cardBg,
          ),

          // Completed Tasks
          _buildKpiCard(
            title: lang?.completed ?? 'Completed',
            value: controller.completedTasksCount.toString(),
            icon: Icons.check_circle_rounded,
            color: AppColors.statusCompleted,
            isDark: isDark,
            cardBg: cardBg,
          ),

          // Pending Tasks
          _buildKpiCard(
            title: lang?.pending ?? 'Pending',
            value: controller.pendingTasksCount.toString(),
            icon: Icons.pending_actions_rounded,
            color: AppColors.statusPending,
            isDark: isDark,
            cardBg: cardBg,
          ),

          // Efficiency Rate
          _buildKpiCard(
            title: 'Efficiency Rate',
            value: '${controller.completionRatePercentage}%',
            icon: Icons.auto_graph_rounded,
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            cardBg: cardBg,
          ),
        ],
      );
    });
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color cardBg,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16.r),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.bold(
              fontSize: 22.sp,
              color: isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Completion Pie / Donut Chart
  Widget _buildCompletionPieChartCard(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color primaryColor,
  ) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Status Overview',
            style: AppTextStyles.bold(
              fontSize: 16.sp,
              color: isDark
                  ? AppColors.darkPrimaryText
                  : AppColors.lightPrimaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Ratio of completed vs pending tasks',
            style: AppTextStyles.regular(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
          SizedBox(height: 20.h),
          Obx(() {
            final completed = controller.completedTasksCount.toDouble();
            final pending = controller.pendingTasksCount.toDouble();
            final total = controller.totalTasksCount;

            if (total == 0) {
              return _buildEmptyChartPlaceholder(
                isDark,
                'No task data available',
              );
            }

            return Row(
              children: [
                SizedBox(
                  height: 140.r,
                  width: 140.r,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 36.r,
                      sections: [
                        PieChartSectionData(
                          color: AppColors.statusCompleted,
                          value: completed > 0 ? completed : 0.001,
                          title: '${controller.completionRatePercentage}%',
                          radius: 32.r,
                          titleStyle: AppTextStyles.bold(
                            fontSize: 11.sp,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppColors.statusPending,
                          value: pending > 0 ? pending : 0.001,
                          title:
                              '${100 - controller.completionRatePercentage}%',
                          radius: 32.r,
                          titleStyle: AppTextStyles.bold(
                            fontSize: 11.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChartLegendItem(
                        color: AppColors.statusCompleted,
                        label: 'Completed Tasks',
                        value: '${completed.toInt()} tasks',
                        isDark: isDark,
                      ),
                      SizedBox(height: 12.h),
                      _buildChartLegendItem(
                        color: AppColors.statusPending,
                        label: 'Pending Tasks',
                        value: '${pending.toInt()} tasks',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChartLegendItem({
    required Color color,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 12.r,
          height: 12.r,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.medium(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bold(
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.lightPrimaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChartPlaceholder(bool isDark, String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.regular(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.darkSecondaryText
                : AppColors.lightSecondaryText,
          ),
        ),
      ),
    );
  }
}
