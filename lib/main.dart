import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/task_storage_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  await TaskStorageService().init();
  await NotificationService().init();

  try {
    await WidgetService().init();
  } catch (e) {
    // Widget service may fail if not supported
    debugPrint('Widget service init error: $e');
  }

  runApp(
    const ProviderScope(
      child: VoiceTaskApp(),
    ),
  );
}
