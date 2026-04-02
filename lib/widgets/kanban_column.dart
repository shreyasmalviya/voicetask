import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';
import 'empty_state.dart';

class KanbanColumn extends ConsumerWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final Function(Task) onTaskTap;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Task>(
      onAcceptWithDetails: (details) {
        final task = details.data;
        if (task.status != status) {
          ref.read(taskListProvider.notifier).moveTask(task.id, status);
        }
      },
      onWillAcceptWithDetails: (details) => details.data.status != status,
      builder: (context, candidateData, rejectedData) {
        final isReceiving = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isReceiving
                ? AppColors.statusColor(status.name).withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isReceiving
                ? Border.all(
                    color:
                        AppColors.statusColor(status.name).withOpacity(0.3),
                    width: 2,
                  )
                : null,
          ),
          child: tasks.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return LongPressDraggable<Task>(
                      data: task,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Opacity(
                            opacity: 0.85,
                            child: TaskCard(task: task),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: TaskCard(task: task),
                      ),
                      child: TaskCard(
                        task: task,
                        onTap: () => onTaskTap(task),
                        onStatusChanged: (newStatus) {
                          ref
                              .read(taskListProvider.notifier)
                              .moveTask(task.id, newStatus);
                        },
                        onDelete: () {
                          ref
                              .read(taskListProvider.notifier)
                              .deleteTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${task.title} deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: AppColors.primary,
                                onPressed: () {
                                  ref
                                      .read(taskListProvider.notifier)
                                      .addTask(task);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    switch (status) {
      case TaskStatus.todo:
        return EmptyStateWidget.todo();
      case TaskStatus.inprogress:
        return EmptyStateWidget.inProgress();
      case TaskStatus.done:
        return EmptyStateWidget.done();
    }
  }
}
