import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic_rounded,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome to\nVoiceTask',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Speak your tasks, let AI organize them',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Quick tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: const Column(
                  children: [
                    _TipRow(
                      icon: Icons.mic_rounded,
                      color: AppColors.primary,
                      text: 'Tap the mic to speak your tasks',
                    ),
                    SizedBox(height: 16),
                    _TipRow(
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.secondary,
                      text: 'AI parses tasks, dates & priority',
                    ),
                    SizedBox(height: 16),
                    _TipRow(
                      icon: Icons.swipe_right_rounded,
                      color: AppColors.inProgressColor,
                      text: 'Swipe right to move tasks forward',
                    ),
                    SizedBox(height: 16),
                    _TipRow(
                      icon: Icons.swipe_left_rounded,
                      color: AppColors.error,
                      text: 'Swipe left to delete a task',
                    ),
                    SizedBox(height: 16),
                    _TipRow(
                      icon: Icons.drag_indicator_rounded,
                      color: AppColors.doneColor,
                      text: 'Long press to drag between columns',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .setOnboardingComplete();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _TipRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
