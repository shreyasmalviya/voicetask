import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../providers/task_provider.dart';
import '../widgets/kanban_column.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/task_list_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _viewMode = 0; // 0 = Board, 1 = List, 2 = Dashboard

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openTaskDetail(Task task) {
    Navigator.of(context).pushNamed('/task-detail', arguments: task);
  }

  @override
  Widget build(BuildContext context) {
    final todoTasks = ref.watch(todoTasksProvider);
    final inProgressTasks = ref.watch(inProgressTasksProvider);
    final doneTasks = ref.watch(doneTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.task_alt_rounded,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              'VoiceTask',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // View Mode Selector
          PopupMenuButton<int>(
            icon: const Icon(Icons.view_carousel_rounded, color: AppColors.textSecondary),
            color: AppColors.surface,
            onSelected: (val) => setState(() => _viewMode = val),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.view_column_rounded, color: _viewMode == 0 ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('Board View', style: TextStyle(color: _viewMode == 0 ? AppColors.primary : AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, color: _viewMode == 1 ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('List View', style: TextStyle(color: _viewMode == 1 ? AppColors.primary : AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.dashboard_rounded, color: _viewMode == 2 ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('Dashboard', style: TextStyle(color: _viewMode == 2 ? AppColors.primary : AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
        bottom: _viewMode == 0 ? PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.surfaceVariant,
              ),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.todoColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('To Do (${todoTasks.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.inProgressColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Active (${inProgressTasks.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.doneColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('Done (${doneTasks.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) : null,
      ),
      body: _viewMode == 0 
        ? TabBarView(
            controller: _tabController,
            children: [
              KanbanColumn(
                status: TaskStatus.todo,
                tasks: todoTasks,
                onTaskTap: _openTaskDetail,
              ),
              KanbanColumn(
                status: TaskStatus.inprogress,
                tasks: inProgressTasks,
                onTaskTap: _openTaskDetail,
              ),
              KanbanColumn(
                status: TaskStatus.done,
                tasks: doneTasks,
                onTaskTap: _openTaskDetail,
              ),
            ],
          )
        : _viewMode == 1
          ? TaskListView(onTaskTap: _openTaskDetail)
          : const DashboardView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pushNamed('/voice');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
