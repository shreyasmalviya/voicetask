import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import 'priority_badge.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final Function(TaskStatus)? onStatusChanged;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
    this.onDelete,
  });

  TaskStatus? get _nextStatus {
    switch (task.status) {
      case TaskStatus.todo:
        return TaskStatus.inprogress;
      case TaskStatus.inprogress:
        return TaskStatus.done;
      case TaskStatus.done:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right — move to next column
          HapticFeedback.lightImpact();
          final next = _nextStatus;
          if (next != null) {
            onStatusChanged?.call(next);
          }
          return false; // Don't dismiss, just change status
        } else {
          // Swipe left — delete
          HapticFeedback.mediumImpact();
          return true;
        }
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: _nextStatus != null
              ? AppColors.statusColor(_nextStatus!.name).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _nextStatus != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.statusColor(_nextStatus!.name),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _nextStatus == TaskStatus.inprogress
                        ? 'In Progress'
                        : 'Done',
                    style: TextStyle(
                      color: AppColors.statusColor(_nextStatus!.name),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : null,
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.statusColor(task.status.name).withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.statusColor(task.status.name).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.statusColor(task.status.name),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.statusColor(task.status.name)
                              .withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: task.priority),
                ],
              ),
              if (task.notes != null && task.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.notes!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  if (task.dueDate != null) ...[
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: _isDueSoon(task.dueDate!)
                          ? AppColors.error
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDueDate(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _isDueSoon(task.dueDate!)
                            ? AppColors.error
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      if (date.hour != 0 || date.minute != 0) {
        return 'Today ${DateFormat.jm().format(date)}';
      }
      return 'Today';
    } else if (taskDate == tomorrow) {
      if (date.hour != 0 || date.minute != 0) {
        return 'Tomorrow ${DateFormat.jm().format(date)}';
      }
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      return 'Overdue · ${DateFormat.MMMd().format(date)}';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  bool _isDueSoon(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now) || date.difference(now).inHours < 2;
  }
}
