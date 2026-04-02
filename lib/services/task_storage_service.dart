import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskStorageService {
  static const String _boxName = 'tasks';
  static const String _settingsBoxName = 'settings';
  late Box<Task> _taskBox;
  late Box _settingsBox;

  static final TaskStorageService _instance = TaskStorageService._internal();
  factory TaskStorageService() => _instance;
  TaskStorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }

    _taskBox = await Hive.openBox<Task>(_boxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // ---- Task CRUD ----

  List<Task> getAllTasks() {
    return _taskBox.values.where((t) => !t.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return _taskBox.values
        .where((t) => t.status == status && !t.isArchived)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Task> getArchivedTasks() {
    return _taskBox.values.where((t) => t.isArchived).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Task? getTask(String id) {
    try {
      return _taskBox.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  Future<void> moveTask(String id, TaskStatus newStatus) async {
    final task = getTask(id);
    if (task != null) {
      task.status = newStatus;
      task.updatedAt = DateTime.now();
      await _taskBox.put(id, task);
    }
  }

  /// Archive all done tasks (called at end of day)
  Future<int> archiveDoneTasks() async {
    final doneTasks = getTasksByStatus(TaskStatus.done);
    int count = 0;
    for (final task in doneTasks) {
      task.isArchived = true;
      task.updatedAt = DateTime.now();
      await _taskBox.put(task.id, task);
      count++;
    }
    return count;
  }

  Future<void> clearCompletedTasks() async {
    final doneTasks = _taskBox.values
        .where((t) => t.status == TaskStatus.done)
        .toList();
    for (final task in doneTasks) {
      await _taskBox.delete(task.id);
    }
  }

  // ---- Settings ----

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  bool get isOnboardingComplete =>
      _settingsBox.get('onboarding_complete', defaultValue: false) as bool;

  Future<void> setOnboardingComplete(bool value) async {
    await _settingsBox.put('onboarding_complete', value);
  }



  int get notificationHour =>
      _settingsBox.get('notification_hour', defaultValue: 21) as int;

  int get notificationMinute =>
      _settingsBox.get('notification_minute', defaultValue: 0) as int;

  Future<void> setNotificationTime(int hour, int minute) async {
    await _settingsBox.put('notification_hour', hour);
    await _settingsBox.put('notification_minute', minute);
  }
}
