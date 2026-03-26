import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.big = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(big ? AppSpacing.xl : AppSpacing.lg),
        child: Row(
          children: [
            _IconBadge(icon: icon, color: accentColor, big: big),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: big
                        ? Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            )
                        : Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
    required this.big,
  });

  final IconData icon;
  final Color color;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: big ? 56 : 44,
      height: big ? 56 : 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

