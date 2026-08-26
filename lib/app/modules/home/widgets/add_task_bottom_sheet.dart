import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/app/core/themes/app_colors.dart';
import 'package:task_manager/app/core/themes/app_textstyle.dart';
import 'package:task_manager/app/core/utils/alert_message_utils.dart';
import 'package:task_manager/app/core/utils/session_manager.dart';
import 'package:task_manager/app/core/widgets/custom_fillable_text_field.dart';
import 'package:task_manager/app/models/task_model.dart';
import 'package:task_manager/app/modules/home/home_controller.dart';
import 'package:task_manager/app/services/auth_service.dart';
import 'package:task_manager/app/services/notification_service.dart';
import 'package:task_manager/app/services/task_service.dart';
import 'package:task_manager/app/services/network_service.dart';
import 'package:task_manager/app/modules/dashboard/dashboard_controller.dart';
import 'package:task_manager/app/localizations/language.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final TaskModel? taskToEdit;

  const AddTaskBottomSheet({super.key, this.taskToEdit});

  static void show(BuildContext context, {TaskModel? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheet(taskToEdit: taskToEdit),
    );
  }

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ScrollController _categoryScrollController = ScrollController();

  String _selectedCategory = '';
  String _selectedPriority = 'Low';
  DateTime _selectedDueDate = DateTime.now();
  TimeOfDay _selectedDueTime = TimeOfDay.now();

  bool _isLoading = false;

  final List<Map<String, dynamic>> _priorities = [
    {'name': 'Low', 'color': const Color(0xFF10B981)},
    {'name': 'Medium', 'color': const Color(0xFFF59E0B)},
    {'name': 'High', 'color': const Color(0xFFEF4444)},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');

    if (widget.taskToEdit != null) {
      _selectedCategory = widget.taskToEdit!.category;
      _selectedPriority = widget.taskToEdit!.priority;
      _selectedDueDate = widget.taskToEdit!.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(widget.taskToEdit!.dueDate);
    } else {
      _selectedPriority = 'Low';
      final now = DateTime.now();
      _selectedDueDate = now;
      _selectedDueTime = TimeOfDay.fromDateTime(now);

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        final validCategories = homeController.categories.where((c) => c != 'All').toList();
        if (validCategories.isNotEmpty) {
          _selectedCategory = validCategories[0];
        }
      }
    }
  }

  final Map<int, GlobalKey> _categoryKeys = {};

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollToCategoryIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _categoryKeys[index];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
      }
    });
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDueTime.hour,
          _selectedDueTime.minute,
        );
      });
    }
  }

  String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickDueTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDueTime = pickedTime;
        _selectedDueDate = DateTime(
          _selectedDueDate.year,
          _selectedDueDate.month,
          _selectedDueDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _saveTask() async {
    if (!NetworkService.checkOnlineOrShowAlert()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final alerts = Get.find<AlertMessageUtils>();

    if (title.isEmpty) {
      alerts.showErrorSnackBar(
        title: 'Title Required',
        message: 'Please enter a title for your task',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseUser = AuthService.currentUser;
      String userId = firebaseUser?.uid ?? '';

      if (userId.isEmpty) {
        userId = await SessionManager().getUserID();
      }

      if (userId.isEmpty) {
        userId = 'guest_user';
      }

      DateTime taskDueDate = DateTime(
        _selectedDueDate.year,
        _selectedDueDate.month,
        _selectedDueDate.day,
        _selectedDueTime.hour,
        _selectedDueTime.minute,
      );

      final now = DateTime.now();
      if (taskDueDate.year == now.year &&
          taskDueDate.month == now.month &&
          taskDueDate.day == now.day &&
          taskDueDate.hour == now.hour &&
          taskDueDate.minute == now.minute &&
          !taskDueDate.isAfter(now)) {
        taskDueDate = now.add(const Duration(seconds: 5));
      }

      final bool isPastTime = taskDueDate.isBefore(now.subtract(const Duration(minutes: 2)));
      if (isPastTime) {
        alerts.showCustomSnackBar(
          message: 'Task date/time is in the past. Notifications will only fire for future tasks.',
        );
      }

      if (widget.taskToEdit != null) {
        // Edit Task
        final updatedTask = widget.taskToEdit!.copyWith(
          title: title,
          description: description,
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: taskDueDate,
        );
        await TaskService.updateTask(updatedTask);
        if (updatedTask.isCompleted) {
          await NotificationService().cancelTaskNotifications(updatedTask.id);
        } else {
          await NotificationService().scheduleTaskNotifications(updatedTask);
        }
        alerts.showSuccessSnackBar(
          title: 'Task Updated',
          message: 'Your task "$title" has been updated.',
        );
      } else {
        // Create New Task
        final newTask = TaskModel(
          id: '',
          userId: userId,
          title: title,
          description: description,
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: taskDueDate,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        final createdTask = await TaskService.addTask(newTask);
        await NotificationService().scheduleTaskNotifications(createdTask);
        alerts.showSuccessSnackBar(
          title: 'Task Created',
          message: 'New task "$title" added successfully.',
        );
      }

      if (mounted) {
        Navigator.pop(context);
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().changeTabIndex(0);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      alerts.showErrorSnackBar(
        title: 'Error Saving Task',
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;
    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkScaffoldBackground : AppColors.lightScaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.taskToEdit != null
                      ? (lang?.editTask ?? 'Edit Task')
                      : (lang?.addNewTask ?? 'Create New Task'),
                  style: AppTextStyles.bold(
                    fontSize: 20.sp,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // 1. Task Title Input
            Text(
              lang?.taskTitleHint ?? 'Task Title *',
              style: AppTextStyles.medium(
                fontSize: 13.sp,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
            SizedBox(height: 6.h),
            CustomFillableTextField(
              controller: _titleController,
              hint: 'Enter task title',
              isDark: isDark,
              fillColor: cardBg,
              textInputAction: TextInputAction.next,
            ),

            SizedBox(height: 16.h),

            // 2. Description / Notes Input
            Text(
              lang?.taskDescriptionHint ?? 'Description (Optional)',
              style: AppTextStyles.medium(
                fontSize: 13.sp,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
            SizedBox(height: 6.h),
            CustomFillableTextField(
              controller: _descriptionController,
              hint: 'Enter description',
              isDark: isDark,
              fillColor: cardBg,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),

            SizedBox(height: 18.h),

            // 3. Category Selector (Real-Time Loaded from Firestore)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang?.selectCategory ?? 'Category',
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                ),
                if (homeController != null)
                  GestureDetector(
                    onTap: () {
                      homeController.showAddCategoryDialog(
                        context,
                        onCategoryAdded: (newCategory) {
                          setState(() {
                            _selectedCategory = newCategory;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCategoryIndex(0);
                          });
                        },
                      );
                    },
                    child: Text(
                      '+ Add New',
                      style: AppTextStyles.bold(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(
              () {
                final categoryList = homeController != null
                    ? homeController.categories.where((c) => c != 'All').toList()
                    : <String>[];

                if (categoryList.isNotEmpty && !categoryList.contains(_selectedCategory)) {
                  _selectedCategory = categoryList.first;
                }

                return SingleChildScrollView(
                  controller: _categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ...categoryList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final cat = entry.value;
                        _categoryKeys[index] ??= GlobalKey();
                        final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
                        final catColor = AppColors.getCategoryColor(cat);
                        final isDeletable = categoryList.length > 1;

                        return GestureDetector(
                          key: _categoryKeys[index],
                          onTap: () {
                            setState(() => _selectedCategory = cat);
                            _scrollToCategoryIndex(index);
                          },
                          onLongPress: () {
                            if (isDeletable && homeController != null) {
                              homeController.confirmDeleteCategory(
                                context,
                                cat,
                                onDeleted: () {
                                  setState(() {
                                    final remaining = homeController.categories.where((c) => c != 'All').toList();
                                    if (remaining.isNotEmpty) {
                                      _selectedCategory = remaining.first;
                                    }
                                  });
                                },
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? catColor
                                  : (isDark ? AppColors.darkCardBackground : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected ? catColor : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.label_outline_rounded,
                                  size: 15.r,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  lang?.getCategoryName(cat) ?? cat,
                                  style: isSelected
                                      ? AppTextStyles.bold(fontSize: 13.sp, color: Colors.white)
                                      : AppTextStyles.medium(
                                          fontSize: 13.sp,
                                          color: isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.lightSecondaryText,
                                        ),
                                ),
                                if (isDeletable) ...[
                                  SizedBox(width: 6.w),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      if (homeController != null) {
                                        homeController.confirmDeleteCategory(
                                          context,
                                          cat,
                                          onDeleted: () {
                                            setState(() {
                                              final remaining = homeController.categories.where((c) => c != 'All').toList();
                                              if (remaining.isNotEmpty) {
                                                _selectedCategory = remaining.first;
                                              }
                                            });
                                          },
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(2.r),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 14.r,
                                        color: isSelected
                                            ? Colors.white.withAlpha(220)
                                            : (isDark ? Colors.redAccent[100] : Colors.red[400]),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 18.h),

            // 4. Priority Selector
            Text(
              lang?.selectPriority ?? 'Priority Level',
              style: AppTextStyles.medium(
                fontSize: 13.sp,
                color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: _priorities.map((pri) {
                final isSelected = _selectedPriority == pri['name'];
                final priColor = pri['color'] as Color;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = pri['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? priColor.withAlpha(isDark ? 50 : 35)
                            : (isDark ? AppColors.darkCardBackground : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? priColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          lang?.getPriorityName(pri['name']) ?? pri['name'],
                          style: isSelected
                              ? AppTextStyles.bold(fontSize: 13.sp, color: priColor)
                              : AppTextStyles.medium(
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 18.h),

            // 5. Due Date & Due Time Tiles
            Row(
              children: [
                // Date Tile
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDueDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18.r,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang?.selectDate ?? 'Due Date',
                                  style: AppTextStyles.regular(
                                    fontSize: 11.sp,
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightSecondaryText,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedDueDate),
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
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 10.w),

                // Time Tile
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDueTime,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 18.r,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang?.selectTime ?? 'Due Time',
                                  style: AppTextStyles.regular(
                                    fontSize: 11.sp,
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightSecondaryText,
                                  ),
                                ),
                                Text(
                                  _formatTime12Hour(_selectedDueTime),
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
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 28.h),

            // Save Task Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  foregroundColor: isDark ? AppColors.darkScaffoldBackground : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.darkScaffoldBackground : Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.taskToEdit != null
                            ? (lang?.updateTask ?? 'Update Task')
                            : (lang?.createTask ?? 'Create Task'),
                        style: AppTextStyles.bold(
                          fontSize: 16.sp,
                          color: isDark ? AppColors.darkScaffoldBackground : Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 12.h),
          ],
        ),
      ),
    ),
  );
}
}
