import 'package:hive/hive.dart';

import 'focus_session_record.dart';

class AnalyticsRepository {
  AnalyticsRepository(this._box);

  final Box<FocusSessionRecord> _box;

  Stream<BoxEvent> watch() => _box.watch();

  List<FocusSessionRecord> getAll() {
    final list = _box.values.toList(growable: false);
    list.sort((a, b) => b.endedAtEpochMs.compareTo(a.endedAtEpochMs));
    return list;
  }

  Future<void> addSession(FocusSessionRecord record) async {
    await _box.add(record);
  }
}

