import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TaskPriority _priority;
  late TaskStatus _status;

  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _priority = widget.task.priority;
    _status = widget.task.status;

    _dueDate = widget.task.dueDate;
    if (_dueDate != null) {
      _dueTime = TimeOfDay(hour: _dueDate!.hour, minute: _dueDate!.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _autoSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return; // Don't auto-save empty title

    DateTime? finalDueDate;
    if (_dueDate != null) {
      if (_dueTime != null) {
        finalDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      } else {
        finalDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
        );
      }
    }

    final updatedTask = widget.task.copyWith(
      title: title,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      priority: _priority,
      status: _status,
      dueDate: finalDueDate,
    );

    ref.read(taskListProvider.notifier).updateTask(updatedTask);
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(taskListProvider.notifier).deleteTask(widget.task.id);
      HapticFeedback.mediumImpact();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
      _autoSave();
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _dueTime = time;
      });
      _autoSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildSectionLabel('TITLE'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (_) => _autoSave(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Task title',
              ),
            ),

            const SizedBox(height: 24),

            // Notes
            _buildSectionLabel('NOTES'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              onChanged: (_) => _autoSave(),
              maxLines: 4,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Add notes...',
              ),
            ),

            const SizedBox(height: 24),

            // Due Date
            _buildSectionLabel('DUE DATE & TIME'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Text(
                            _dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : 'Set date',
                            style: TextStyle(
                              color: _dueDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _dueDate != null ? _selectTime : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Text(
                            _dueTime != null ? _dueTime!.format(context) : 'Set time',
                            style: TextStyle(
                              color: _dueTime != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_dueDate != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _dueDate = null;
                    _dueTime = null;
                  });
                  _autoSave();
                },
                child: const Text(
                  'Clear date',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Priority
            _buildSectionLabel('PRIORITY'),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((p) {
                final isSelected = _priority == p;
                final color = AppColors.priorityColor(p.name);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _priority = p;
                      });
                      HapticFeedback.selectionClick();
                      _autoSave();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p == TaskPriority.high
                                ? 'High'
                                : p == TaskPriority.medium
                                    ? 'Medium'
                                    : 'Low',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? color : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Status
            _buildSectionLabel('STATUS'),
            const SizedBox(height: 8),
            Row(
              children: TaskStatus.values.map((s) {
                final isSelected = _status == s;
                final color = AppColors.statusColor(s.name);
                final label = s == TaskStatus.todo
                    ? 'To Do'
                    : s == TaskStatus.inprogress
                        ? 'In Progress'
                        : 'Done';
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _status = s;
                      });
                      HapticFeedback.selectionClick();
                      _autoSave();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color.withOpacity(0.5) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Metadata
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildMetaRow(
                    'Created',
                    DateFormat.yMMMd().add_jm().format(widget.task.createdAt),
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(
                    'Updated',
                    DateFormat.yMMMd().add_jm().format(widget.task.updatedAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
