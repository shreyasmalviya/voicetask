import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/task_storage_service.dart';
import '../services/widget_service.dart';
import '../services/notification_service.dart';

// Task storage service singleton provider
final taskStorageProvider = Provider<TaskStorageService>((ref) {
  return TaskStorageService();
});

// Widget service singleton provider
final widgetServiceProvider = Provider<WidgetService>((ref) {
  return WidgetService();
});

// Notification service singleton provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Main task list state
final taskListProvider =
    StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier(ref);
});

// Filtered providers
final todoTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks
      .where((t) => t.status == TaskStatus.todo && !t.isArchived)
      .toList();
});

final inProgressTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks
      .where((t) => t.status == TaskStatus.inprogress && !t.isArchived)
      .toList();
});

final doneTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks
      .where((t) => t.status == TaskStatus.done && !t.isArchived)
      .toList();
});

class TaskListNotifier extends StateNotifier<List<Task>> {
  final Ref _ref;

  TaskListNotifier(this._ref) : super([]) {
    _loadTasks();
  }

  TaskStorageService get _storage => _ref.read(taskStorageProvider);
  WidgetService get _widget => _ref.read(widgetServiceProvider);
  NotificationService get _notification =>
      _ref.read(notificationServiceProvider);

  void _loadTasks() {
    state = _storage.getAllTasks();
  }

  Future<void> addTask(Task task) async {
    await _storage.addTask(task);

    // Schedule notification if due date exists
    if (task.dueDate != null) {
      await _notification.scheduleTaskReminder(task);
    }

    _loadTasks();
    await _updateWidget();
  }

  Future<void> addTasks(List<Task> tasks) async {
    for (final task in tasks) {
      await addTask(task);
    }
  }

  Future<void> updateTask(Task task) async {
    await _storage.updateTask(task);

    // Reschedule notification
    await _notification.cancelTaskReminder(task.id);
    if (task.dueDate != null && task.status != TaskStatus.done) {
      await _notification.scheduleTaskReminder(task);
    }

    _loadTasks();
    await _updateWidget();
  }

  Future<void> deleteTask(String taskId) async {
    // Cancel notification
    await _notification.cancelTaskReminder(taskId);

    await _storage.deleteTask(taskId);
    _loadTasks();
    await _updateWidget();
  }

  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    await _storage.moveTask(taskId, newStatus);

    // Cancel reminder if done
    if (newStatus == TaskStatus.done) {
      await _notification.cancelTaskReminder(taskId);
    }

    _loadTasks();
    await _updateWidget();
  }

  Future<void> archiveDoneTasks() async {
    final count = await _storage.archiveDoneTasks();
    if (count > 0) {
      await _notification.showArchiveNotification(count);
    }
    _loadTasks();
    await _updateWidget();
  }

  Future<void> clearCompleted() async {
    await _storage.clearCompletedTasks();
    _loadTasks();
    await _updateWidget();
  }

  void refresh() {
    _loadTasks();
  }

  Future<void> _updateWidget() async {
    try {
      await _widget.updateWidgetData(state);
    } catch (e) {
      // Widget update is non-critical
      print('Widget update error: $e');
    }
  }
}
