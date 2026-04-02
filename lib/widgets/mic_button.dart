import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class MicButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const MicButton({
    super.key,
    this.isListening = false,
    this.onPressed,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _scaleController.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        _scaleController.reverse();
      },
      onLongPressStart: (_) {
        HapticFeedback.mediumImpact();
        widget.onLongPressStart?.call();
      },
      onLongPressEnd: (_) {
        HapticFeedback.lightImpact();
        _scaleController.reverse();
        widget.onLongPressEnd?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _scaleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse rings (only when listening)
                  if (widget.isListening) ...[
                    _buildPulseRing(80, _pulseAnimation.value * 1.3, 0.08),
                    _buildPulseRing(70, _pulseAnimation.value * 1.15, 0.12),
                    _buildPulseRing(60, _pulseAnimation.value, 0.18),
                  ],
                  // Main button
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isListening
                          ? const LinearGradient(
                              colors: [
                                AppColors.micRecording,
                                Color(0xFFDC2626),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isListening
                                  ? AppColors.micRecording
                                  : AppColors.primary)
                              .withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isListening ? Icons.mic : Icons.mic_none_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(
      double baseSize, double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: baseSize,
        height: baseSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: (widget.isListening
                    ? AppColors.micRecording
                    : AppColors.primary)
                .withValues(alpha: opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}
