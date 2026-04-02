import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/task_storage_service.dart';
import '../services/notification_service.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final TimeOfDay notificationTime;
  final bool isOnboardingComplete;

  const SettingsState({
    this.notificationTime = const TimeOfDay(hour: 21, minute: 0),
    this.isOnboardingComplete = false,
  });

  SettingsState copyWith({
    TimeOfDay? notificationTime,
    bool? isOnboardingComplete,
  }) {
    return SettingsState(
      notificationTime: notificationTime ?? this.notificationTime,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final TaskStorageService _storage = TaskStorageService();
  final NotificationService _notification = NotificationService();

  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = SettingsState(
      notificationTime: TimeOfDay(
        hour: _storage.notificationHour,
        minute: _storage.notificationMinute,
      ),
      isOnboardingComplete: _storage.isOnboardingComplete,
    );
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    await _storage.setNotificationTime(time.hour, time.minute);
    await _notification.scheduleDailySummary(time.hour, time.minute);
    state = state.copyWith(notificationTime: time);
  }

  Future<void> setOnboardingComplete() async {
    await _storage.setOnboardingComplete(true);
    state = state.copyWith(isOnboardingComplete: true);
  }
}
