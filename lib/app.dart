import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'models/task.dart';
import 'providers/settings_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/voice_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/settings_screen.dart';

class VoiceTaskApp extends ConsumerWidget {
  const VoiceTaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'VoiceTask',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: settings.isOnboardingComplete ? '/home' : '/onboarding',
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/onboarding':
            return MaterialPageRoute(
              builder: (_) => const OnboardingScreen(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
          case '/voice':
            return MaterialPageRoute(
              builder: (_) => const VoiceScreen(),
              fullscreenDialog: true,
            );
          case '/task-detail':
            final task = routeSettings.arguments as Task;
            return MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
        }
      },
    );
  }
}
