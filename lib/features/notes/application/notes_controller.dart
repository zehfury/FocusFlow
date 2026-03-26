import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/note_record.dart';
import '../data/notes_persistence.dart';
import '../data/notes_repository.dart';

class NotesState {
  const NotesState({
    required this.items,
    required this.isReady,
  });

  final List<({int key, NoteRecord note})> items;
  final bool isReady;

  NotesState copyWith({
    List<({int key, NoteRecord note})>? items,
    bool? isReady,
  }) {
    return NotesState(
      items: items ?? this.items,
      isReady: isReady ?? this.isReady,
    );
  }
}

class NotesController extends Notifier<NotesState> {
  NotesRepository? _repo;
  StreamSubscription? _sub;

  @override
  NotesState build() {
    ref.onDispose(() {
      unawaited(_sub?.cancel());
    });

    final box = tryGetNotesBox();
    if (box == null) {
      return const NotesState(items: [], isReady: false);
    }

    _repo = NotesRepository(box);

    // Refresh on any box event.
    _sub = _repo!.watch().listen((_) => _refresh());

    return NotesState(items: _repo!.getAll(), isReady: true);
  }

  void _refresh() {
    final repo = _repo;
    if (repo == null) return;
    state = state.copyWith(items: repo.getAll(), isReady: true);
  }

  Future<void> add({
    required String title,
    required String content,
  }) async {
    final repo = _repo;
    if (repo == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.add(
      NoteRecord(title: title, content: content, timestampEpochMs: now),
    );
    _refresh();
  }

  Future<void> update({
    required int key,
    required String title,
    required String content,
  }) async {
    final repo = _repo;
    if (repo == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.update(
      key,
      NoteRecord(title: title, content: content, timestampEpochMs: now),
    );
    _refresh();
  }

  Future<void> delete(int key) async {
    final repo = _repo;
    if (repo == null) return;
    await repo.delete(key);
    _refresh();
  }

  NoteRecord? get(int key) => _repo?.get(key);
}

final notesProvider =
    NotifierProvider<NotesController, NotesState>(NotesController.new);

