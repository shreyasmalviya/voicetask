import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';
import '../services/gemini_service.dart';
import '../providers/task_provider.dart';
import '../widgets/mic_button.dart';
import '../widgets/priority_badge.dart';
import 'package:intl/intl.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final GeminiService _gemini = GeminiService();

  bool _isListening = false;
  bool _isParsing = false;
  List<Task> _parsedTasks = [];
  String? _error;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/voice_commands_${DateTime.now().millisecondsSinceEpoch}.wav';

        setState(() {
          _isListening = true;
          _parsedTasks = [];
          _error = null;
        });

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: path,
        );
      } else {
        setState(() => _error = 'Microphone permission denied');
      }
    } catch (e) {
      setState(() {
        _isListening = false;
        _error = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!_isListening) return;

    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isListening = false;
      });

      if (path != null) {
        _parseAudio(path);
      }
    } catch (e) {
      setState(() {
        _isListening = false;
        _error = 'Failed to stop recording: $e';
      });
    }
  }

  Future<void> _parseAudio(String audioPath) async {
    setState(() {
      _isParsing = true;
      _error = null;
    });

    try {
      final file = File(audioPath);
      if (!file.existsSync() || file.lengthSync() == 0) {
        throw Exception("Audio file is empty or corrupted. Microphone may not be capturing.");
      }

      final tasks = await _gemini.parseTasksFromAudio(audioPath);
      
      setState(() {
        _parsedTasks = tasks;
        _isParsing = false;
        if (tasks.isEmpty) {
          _error = "No actionable tasks were detected. Try speaking clearer or adding more details.";
        }
      });

      // Try to clean up file after since we sent it
      try {
        file.deleteSync();
      } catch (_) {}
    } catch (e) {
      setState(() {
        _isParsing = false;
        _error = 'Failed to parse tasks: $e';
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _parsedTasks.removeAt(index);
    });
  }

  Future<void> _saveTasks() async {
    if (_parsedTasks.isEmpty) return;

    HapticFeedback.heavyImpact();
    await ref.read(taskListProvider.notifier).addTasks(_parsedTasks);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_parsedTasks.length} task${_parsedTasks.length > 1 ? 's' : ''} added!',
          ),
          backgroundColor: AppColors.success.withOpacity(0.9),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Tasks'),
        actions: [
          if (_parsedTasks.isNotEmpty)
            TextButton.icon(
              onPressed: _saveTasks,
              icon: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 20),
              label: const Text(
                'Save All',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Transcript/Result area
          Expanded(
            child: _parsedTasks.isNotEmpty
                ? _buildParsedTasksList()
                : _buildStatusView(),
          ),

          // Mic button area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0),
                  AppColors.background,
                ],
              ),
            ),
            child: Column(
              children: [
                MicButton(
                  isListening: _isListening,
                  onPressed: () {
                    if (_isListening) {
                      _stopRecording();
                    } else {
                      _startRecording();
                    }
                  },
                  onLongPressStart: _startRecording,
                  onLongPressEnd: _stopRecording,
                ),
                const SizedBox(height: 16),
                Text(
                  _isListening
                      ? 'Listening... Tap to stop'
                      : _isParsing
                          ? 'Sending to Gemini AI...'
                          : 'Tap or hold to speak',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isListening
                        ? AppColors.micRecording
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (!_isListening && !_isParsing) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.mic_none_rounded,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Speak your tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try: "Buy groceries tomorrow and finish\nthe report by Friday, it\'s urgent"',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Powered by Native Gemini Audio', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
          if (_isParsing) ...[
            const SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Transcribing & Analyzing...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sending high-quality audio directly to Gemini',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParsedTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      itemCount: _parsedTasks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_parsedTasks.length} task${_parsedTasks.length > 1 ? 's' : ''} found',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _parsedTasks.clear();
                    });
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        final task = _parsedTasks[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ParsedTaskCard(
            task: task,
            onDelete: () => _removeTask(index - 1),
            onEdit: (editedTask) {
              setState(() {
                _parsedTasks[index - 1] = editedTask;
              });
            },
          ),
        );
      },
    );
  }
}

class _ParsedTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final Function(Task) onEdit;

  const _ParsedTaskCard({
    required this.task,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PriorityBadge(priority: task.priority, showLabel: true),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              task.notes!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (task.dueDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, y · h:mm a').format(task.dueDate!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
