import 'package:hive/hive.dart';

import 'focus_session_record.dart';

class FocusSessionRecordAdapter extends TypeAdapter<FocusSessionRecord> {
  @override
  final int typeId = 44;

  @override
  FocusSessionRecord read(BinaryReader reader) {
    final kindIndex = reader.readInt();
    final durationMs = reader.readInt();
    final endedAtEpochMs = reader.readInt();
    return FocusSessionRecord(
      kindIndex: kindIndex,
      durationMs: durationMs,
      endedAtEpochMs: endedAtEpochMs,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSessionRecord obj) {
    writer.writeInt(obj.kindIndex);
    writer.writeInt(obj.durationMs);
    writer.writeInt(obj.endedAtEpochMs);
  }
}

