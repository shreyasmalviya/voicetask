
import 'package:home_widget/home_widget.dart';
import '../models/task.dart';

class WidgetService {
  static const String _widgetProviderName = 'HomeScreenWidgetProvider';
  static const String _appGroupId = 'group.com.voicetask.app';

  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Update widget with current active tasks (top 3)
  Future<void> updateWidgetData(List<Task> allTasks) async {
    // Get active tasks (not done, not archived), sorted by priority then date
    final activeTasks = allTasks
        .where((t) => t.status != TaskStatus.done && !t.isArchived)
        .toList()
      ..sort((a, b) {
        // Sort by priority first (high > medium > low)
        final priorityOrder = a.priority.index.compareTo(b.priority.index);
        if (priorityOrder != 0) return priorityOrder;
        // Then by due date (soonest first)
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    final topTasks = activeTasks.take(3).toList();

    // Save task count
    await HomeWidget.saveWidgetData<int>('task_count', activeTasks.length);

    // Save individual task data
    for (int i = 0; i < 3; i++) {
      if (i < topTasks.length) {
        final task = topTasks[i];
        await HomeWidget.saveWidgetData<String>('task_title_$i', task.title);
        await HomeWidget.saveWidgetData<String>(
            'task_status_$i', task.status.name);
        await HomeWidget.saveWidgetData<String>(
            'task_priority_$i', task.priority.name);
      } else {
        await HomeWidget.saveWidgetData<String>('task_title_$i', '');
        await HomeWidget.saveWidgetData<String>('task_status_$i', '');
        await HomeWidget.saveWidgetData<String>('task_priority_$i', '');
      }
    }

    // Trigger widget refresh
    await HomeWidget.updateWidget(name: _widgetProviderName);
  }
}
