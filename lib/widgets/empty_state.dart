import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
  });

  factory EmptyStateWidget.todo() {
    return const EmptyStateWidget(
      title: 'No tasks yet',
      subtitle: 'Tap the mic to add your first task',
      icon: Icons.checklist_rounded,
      color: AppColors.todoColor,
    );
  }

  factory EmptyStateWidget.inProgress() {
    return const EmptyStateWidget(
      title: 'Nothing in progress',
      subtitle: 'Swipe a task right to start working on it',
      icon: Icons.trending_up_rounded,
      color: AppColors.inProgressColor,
    );
  }

  factory EmptyStateWidget.done() {
    return const EmptyStateWidget(
      title: 'No completed tasks',
      subtitle: 'Your finished tasks will appear here',
      icon: Icons.celebration_rounded,
      color: AppColors.doneColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow effect
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: effectiveColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: effectiveColor.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 36,
                color: effectiveColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
