import 'package:get/get.dart';
import 'package:task_manager/app/models/task_model.dart';
import 'package:task_manager/app/modules/home/home_controller.dart';

class StatisticsController extends GetxController {
  late HomeController _homeController;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<HomeController>()) {
      _homeController = Get.find<HomeController>();
    } else {
      _homeController = Get.put(HomeController());
    }
  }

  List<TaskModel> get tasks => _homeController.userTasks;

  int get totalTasksCount => tasks.length;
  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => tasks.where((t) => !t.isCompleted).length;

  double get completionRate {
    if (totalTasksCount == 0) return 0.0;
    return (completedTasksCount / totalTasksCount);
  }

  int get completionRatePercentage => (completionRate * 100).round();

  // Priority Metrics
  int get highPriorityCount =>
      tasks.where((t) => t.priority.toLowerCase() == 'high').length;
  int get mediumPriorityCount =>
      tasks.where((t) => t.priority.toLowerCase() == 'medium').length;
  int get lowPriorityCount =>
      tasks.where((t) => t.priority.toLowerCase() == 'low').length;

  // Category Distribution Map
  Map<String, int> get categoryTaskCounts {
    final Map<String, int> counts = {};
    for (final task in tasks) {
      final cat = task.category.isEmpty ? 'General' : task.category;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  // Weekly Completion Trend (Last 7 Days)
  List<Map<String, dynamic>> get weeklyProductivityData {
    final now = DateTime.now();
    final List<Map<String, dynamic>> weeklyData = [];

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = dayNames[date.weekday - 1];

      // Count tasks completed on this date
      final count = tasks.where((t) {
        if (!t.isCompleted) return false;
        return t.dueDate.year == date.year &&
            t.dueDate.month == date.month &&
            t.dueDate.day == date.day;
      }).length;

      weeklyData.add({'day': dayName, 'count': count, 'date': date});
    }

    return weeklyData;
  }
}
