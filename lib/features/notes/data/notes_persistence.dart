import 'package:hive/hive.dart';

import 'note_record.dart';
import 'note_record_adapter.dart';

const notesBoxName = 'notes_box';

Future<void> initNotesPersistence() async {
  if (!Hive.isAdapterRegistered(NoteRecordAdapter().typeId)) {
    Hive.registerAdapter(NoteRecordAdapter());
  }

  if (!Hive.isBoxOpen(notesBoxName)) {
    await Hive.openBox<NoteRecord>(notesBoxName);
  }
}

Box<NoteRecord>? tryGetNotesBox() {
  if (!Hive.isBoxOpen(notesBoxName)) return null;
  return Hive.box<NoteRecord>(notesBoxName);
}

