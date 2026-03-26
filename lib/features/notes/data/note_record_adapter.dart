import 'package:hive/hive.dart';

import 'note_record.dart';

class NoteRecordAdapter extends TypeAdapter<NoteRecord> {
  @override
  final int typeId = 43;

  @override
  NoteRecord read(BinaryReader reader) {
    final title = reader.readString();
    final content = reader.readString();
    final ts = reader.readInt();
    return NoteRecord(
      title: title,
      content: content,
      timestampEpochMs: ts,
    );
  }

  @override
  void write(BinaryWriter writer, NoteRecord obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeInt(obj.timestampEpochMs);
  }
}

