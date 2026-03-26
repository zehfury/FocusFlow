import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/pomodoro_controller.dart';
import '../application/pomodoro_state.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../shared/utils/formatters.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  late double _lastProgress01;

  @override
  void initState() {
    super.initState();
    _lastProgress01 = ref.read(pomodoroProvider).progress01;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pomodoro = ref.watch(pomodoroProvider);
    final progress01 = pomodoro.progress01;
    final progressTween = Tween<double>(
      begin: _lastProgress01,
      end: progress01,
    );
    _lastProgress01 = progress01;

    final modeLabel =
        pomodoro.mode == PomodoroMode.focus ? 'Focus' : 'Break';
    final isRunning = pomodoro.status == PomodoroStatus.running;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: ResponsiveScaffoldBody(
        maxWidth: 620,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _ModePill(
                  label: modeLabel,
                  icon: pomodoro.mode == PomodoroMode.focus
                      ? Icons.center_focus_strong
                      : Icons.coffee_maker,
                  background: colorScheme.primaryContainer,
                  foreground: colorScheme.onPrimaryContainer,
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    isRunning ? 'Running' : 'Paused',
                    key: ValueKey(isRunning),
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = math.min(constraints.maxWidth, constraints.maxHeight);
                  final ringSize = size.clamp(240.0, 360.0);

                  return Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      width: ringSize,
                      height: ringSize,
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.card,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.surface.withValues(alpha: 0.95),
                            colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: TweenAnimationBuilder<double>(
                          tween: progressTween,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedProgress01, child) {
                            return _TimerRing(
                              value: animatedProgress01,
                              trackColor: colorScheme.outlineVariant,
                              progressColor: colorScheme.primary,
                              glowColor:
                                  colorScheme.primary.withValues(alpha: 0.30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    Formatters.formatMMSS(
                                      pomodoro.remainingClamped,
                                    ),
                                    style: textTheme.displaySmall?.copyWith(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    pomodoro.mode == PomodoroMode.focus
                                        ? 'Deep work session'
                                        : 'Recovery break',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isRunning
                        ? null
                        : () => ref.read(pomodoroProvider.notifier).start(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRunning
                        ? () => ref.read(pomodoroProvider.notifier).pause()
                        : null,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 56,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => ref.read(pomodoroProvider.notifier).skip(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.card,
                      ),
                    ),
                    child: const Icon(Icons.skip_next),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => ref.read(pomodoroProvider.notifier).reset(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.value,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
    required this.child,
  });

  final double value;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainter(
        value: value,
        trackColor: trackColor,
        progressColor: progressColor,
        glowColor: glowColor,
      ),
      child: Center(child: child),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
  });

  final double value;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.max(10.0, size.shortestSide * 0.055);
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          progressColor.withValues(alpha: 0.2),
          progressColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final startAngle = -math.pi / 2;
    final sweepAngle = (2 * math.pi) * value.clamp(0.0, 1.0);

    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.glowColor != glowColor;
  }
}

