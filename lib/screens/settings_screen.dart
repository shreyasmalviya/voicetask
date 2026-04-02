import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Notifications
          _buildSectionLabel('NOTIFICATIONS'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: settings.notificationTime,
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
                ref
                    .read(settingsProvider.notifier)
                    .setNotificationTime(time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Summary Time',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Get notified about your daily progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      settings.notificationTime.format(context),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Data
          _buildSectionLabel('DATA'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Completed Tasks'),
                  content: const Text(
                    'This will permanently delete all completed tasks. This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.error),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(taskListProvider.notifier).clearCompleted();
                HapticFeedback.mediumImpact();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completed tasks cleared'),
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cleaning_services_rounded,
                      size: 20, color: AppColors.error),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clear Completed Tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Remove all tasks marked as done',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // App info
          Center(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.task_alt_rounded,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'VoiceTask v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
