import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core backgrounds
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF232340);

  // Brand / Primary
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9B5DE5);
  static const Color primaryDark = Color(0xFF5B21B6);

  // Status colors
  static const Color todoColor = Color(0xFF7C3AED); // Purple
  static const Color inProgressColor = Color(0xFFF59E0B); // Amber
  static const Color doneColor = Color(0xFF10B981); // Green

  // Semantic
  static const Color secondary = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Priority colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // Mic button
  static const Color micIdle = Color(0xFF7C3AED);
  static const Color micRecording = Color(0xFFEF4444);
  static const Color micGlow = Color(0x40EF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9B5DE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF232340)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x1A7C3AED), Color(0x0A7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns color for the given task status
  static Color statusColor(String status) {
    switch (status) {
      case 'todo':
        return todoColor;
      case 'inprogress':
        return inProgressColor;
      case 'done':
        return doneColor;
      default:
        return textSecondary;
    }
  }

  /// Returns color for the given task priority
  static Color priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return textSecondary;
    }
  }
}
