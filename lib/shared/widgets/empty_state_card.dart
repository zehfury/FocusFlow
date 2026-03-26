import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.ctaLabel,
    required this.onCtaPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String ctaLabel;
  final VoidCallback onCtaPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onCtaPressed,
                icon: const Icon(Icons.add),
                label: Text(ctaLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

