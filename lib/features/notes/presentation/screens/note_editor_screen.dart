import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/responsive_scaffold.dart';
import '../../application/notes_controller.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({
    super.key,
    this.noteKey,
  });

  final int? noteKey;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final FocusNode _contentFocus;

  @override
  void initState() {
    super.initState();

    final existing = widget.noteKey == null
        ? null
        : ref.read(notesProvider.notifier).get(widget.noteKey!);

    _titleController = TextEditingController(text: existing?.title ?? '');
    _contentController = TextEditingController(text: existing?.content ?? '');
    _contentFocus = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteKey != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit note' : 'New note'),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: _onSave,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ResponsiveScaffoldBody(
        maxWidth: 680,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _contentFocus.requestFocus(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TextField(
                    controller: _contentController,
                    focusNode: _contentFocus,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      hintText: 'Write your note…',
                      helperText: 'Tip: Swipe left on a note to delete it.',
                      helperStyle: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _onSave,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to save')),
      );
      return;
    }

    final controller = ref.read(notesProvider.notifier);
    if (widget.noteKey == null) {
      await controller.add(title: title, content: content);
    } else {
      await controller.update(key: widget.noteKey!, title: title, content: content);
    }

    if (!mounted) return;
    Navigator.of(context).maybePop();
  }
}

