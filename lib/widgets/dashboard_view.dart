import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_colors.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No stats available.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    final totalTasks = tasks.length;
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    final pendingTasks = totalTasks - doneTasks;
    final highPriority = tasks.where((t) => t.priority == TaskPriority.high && t.status != TaskStatus.done).length;

    // Last 7 days completion data
    final now = DateTime.now();
    final List<int> completionsPerDay = List.filled(7, 0);
    final List<String> daysLabels = List.filled(7, '');
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      daysLabels[i] = DateFormat('E').format(date); // Mon, Tue...
      
      final completedThatDay = tasks.where((t) {
        if (t.status != TaskStatus.done) return false;
        // Use updatedAt as the "completion date" proxy
        return t.updatedAt.year == date.year && 
               t.updatedAt.month == date.month && 
               t.updatedAt.day == date.day;
      }).length;
      
      completionsPerDay[i] = completedThatDay;
    }

    double maxY = completionsPerDay.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxY == 0) maxY = 5; // Default grid height

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stats grid
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending', pendingTasks.toString(), Icons.pending_actions_rounded, AppColors.inProgressColor)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Completed', doneTasks.toString(), Icons.task_alt_rounded, AppColors.doneColor)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
             Expanded(child: _buildStatCard('High Priority', highPriority.toString(), Icons.local_fire_department_rounded, AppColors.error)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Total Tasks', totalTasks.toString(), Icons.list_alt_rounded, AppColors.textPrimary)),
          ],
        ),
        
        const SizedBox(height: 32),
        const Text(
          'Tasks Completed (Last 7 Days)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        
        // Chart
        Container(
          height: 240,
          padding: const EdgeInsets.only(top: 24, right: 24, left: 0, bottom: 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.5)),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= 7) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          daysLabels[index],
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY > 5 ? (maxY / 5).ceilToDouble() : 1,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      if (value != value.toInt()) return const SizedBox.shrink();
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.right,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY + 1, // Add some headroom
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(7, (index) => FlSpot(index.toDouble(), completionsPerDay[index].toDouble())),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.background,
                      strokeWidth: 2,
                      strokeColor: AppColors.primary,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
