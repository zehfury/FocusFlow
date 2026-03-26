import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../application/notes_controller.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state_card.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final items = state.items;
    final df = Formatters.noteTimestampFormatter();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/new'),
        child: const Icon(Icons.add),
      ),
      body: ResponsiveScaffoldBody(
        child: !state.isReady
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? EmptyStateCard(
                    icon: Icons.notes,
                    title: 'Capture ideas quickly',
                    message:
                        'Create notes for tasks, insights, and anything you want to remember.',
                    ctaLabel: 'New note',
                    onCtaPressed: () => context.push('/notes/new'),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final note = item.note;

                      return Dismissible(
                        key: ValueKey(item.key),
                        background: const _DeleteBackground(),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async => true,
                        onDismissed: (_) =>
                            ref.read(notesProvider.notifier).delete(item.key),
                        child: InkWell(
                          borderRadius: AppRadii.card,
                          onTap: () => context.push('/notes/edit/${item.key}'),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.title.isEmpty
                                              ? '(Untitled)'
                                              : note.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest
                                              .withValues(alpha: 0.6),
                                          borderRadius: AppRadii.pill,
                                          border: Border.all(
                                            color: cs.outlineVariant
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.xs,
                                          ),
                                          child: Text(
                                            df.format(note.timestamp),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  if (note.content.isNotEmpty)
                                    Text(
                                      note.content,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                    )
                                  else
                                    Text(
                                      'No content',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withValues(alpha: 0.75),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          ],
        ),
      ),
    );
  }
}

