import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  TaskStatus status;

  @HiveField(4)
  TaskPriority priority;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  bool syncToCalendar;

  @HiveField(7)
  String? calendarEventId;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool isArchived;

  Task({
    required this.id,
    required this.title,
    this.notes,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.syncToCalendar = true,
    this.calendarEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isArchived = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? syncToCalendar,
    String? calendarEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      syncToCalendar: syncToCalendar ?? this.syncToCalendar,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'syncToCalendar': syncToCalendar,
      'calendarEventId': calendarEventId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      syncToCalendar: json['syncToCalendar'] as bool? ?? true,
      calendarEventId: json['calendarEventId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inprogress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  @override
  String toString() => 'Task(id: $id, title: $title, status: ${status.name})';
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,

  @HiveField(1)
  inprogress,

  @HiveField(2)
  done,
}

@HiveType(typeId: 2)
enum TaskPriority {
  @HiveField(0)
  high,

  @HiveField(1)
  medium,

  @HiveField(2)
  low,
}
