import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';
import 'task_card.dart';

class TaskListView extends ConsumerWidget {
  final Function(Task) onTaskTap;

  const TaskListView({super.key, required this.onTaskTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No tasks yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    final overdue = <Task>[];
    final today = <Task>[];
    final upcoming = <Task>[];
    final noDate = <Task>[];

    for (var task in tasks) {
      if (task.status == TaskStatus.done) continue;

      if (task.dueDate == null) {
        noDate.add(task);
      } else {
        final taskDateStr = '${task.dueDate!.year}-${task.dueDate!.month}-${task.dueDate!.day}';
        if (taskDateStr == todayStr) {
          today.add(task);
        } else if (task.dueDate!.isBefore(now)) {
          overdue.add(task);
        } else {
          upcoming.add(task);
        }
      }
    }

    // Sort by priority then date
    int _sortTask(Task a, Task b) {
      if (a.priority.index != b.priority.index) return a.priority.index.compareTo(b.priority.index);
      if (a.dueDate != null && b.dueDate != null) return a.dueDate!.compareTo(b.dueDate!);
      return 0;
    }

    overdue.sort(_sortTask);
    today.sort(_sortTask);
    upcoming.sort(_sortTask);
    noDate.sort(_sortTask);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        if (overdue.isNotEmpty) ...[
          _buildGroupHeader('Overdue', AppColors.error),
          ...overdue.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TaskCard(task: t, onTap: () => onTaskTap(t)))),
          const SizedBox(height: 16),
        ],
        if (today.isNotEmpty) ...[
          _buildGroupHeader('Today', AppColors.primary),
          ...today.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TaskCard(task: t, onTap: () => onTaskTap(t)))),
          const SizedBox(height: 16),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildGroupHeader('Upcoming', AppColors.textPrimary),
          ...upcoming.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TaskCard(task: t, onTap: () => onTaskTap(t)))),
          const SizedBox(height: 16),
        ],
        if (noDate.isNotEmpty) ...[
          _buildGroupHeader('No Date', AppColors.textSecondary),
          ...noDate.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TaskCard(task: t, onTap: () => onTaskTap(t)))),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildGroupHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
