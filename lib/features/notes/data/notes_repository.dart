import 'package:hive/hive.dart';

import 'note_record.dart';

class NotesRepository {
  NotesRepository(this._box);

  final Box<NoteRecord> _box;

  List<({int key, NoteRecord note})> getAll() {
    final entries = <({int key, NoteRecord note})>[];
    for (final key in _box.keys) {
      if (key is! int) continue;
      final note = _box.get(key);
      if (note == null) continue;
      entries.add((key: key, note: note));
    }

    entries.sort((a, b) => b.note.timestampEpochMs.compareTo(a.note.timestampEpochMs));
    return entries;
  }

  Stream<BoxEvent> watch() => _box.watch();

  Future<int> add(NoteRecord note) async {
    return _box.add(note);
  }

  Future<void> update(int key, NoteRecord note) async {
    await _box.put(key, note);
  }

  Future<void> delete(int key) async {
    await _box.delete(key);
  }

  NoteRecord? get(int key) => _box.get(key);
}

