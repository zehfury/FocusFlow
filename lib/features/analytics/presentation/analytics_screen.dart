import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/responsive_scaffold.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/analytics_controller.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/app_stat_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: ResponsiveScaffoldBody(
        maxWidth: 720,
        child: !state.isReady
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppStatCard(
                    title: 'Focus time today',
                    value: Formatters.formatDurationShort(state.totalFocusToday),
                    icon: Icons.center_focus_strong,
                    accentColor: cs.primary,
                    big: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppStatCard(
                          title: 'Completed today',
                          value: '${state.completedFocusSessionsToday}',
                          icon: Icons.check_circle_outline,
                          accentColor: cs.tertiary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppStatCard(
                          title: 'All sessions',
                          value: '${state.totalSessionsAllTime}',
                          icon: Icons.query_stats,
                          accentColor: cs.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How this is tracked',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Every time a Focus session completes, FocusFlow writes a small record '
                            '(duration + end time) to local storage. Analytics sums today’s records.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

