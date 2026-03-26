import 'package:hive/hive.dart';

import 'focus_session_record.dart';
import 'focus_session_record_adapter.dart';

const sessionsBoxName = 'sessions_box';

Future<void> initAnalyticsPersistence() async {
  if (!Hive.isAdapterRegistered(FocusSessionRecordAdapter().typeId)) {
    Hive.registerAdapter(FocusSessionRecordAdapter());
  }

  if (!Hive.isBoxOpen(sessionsBoxName)) {
    await Hive.openBox<FocusSessionRecord>(sessionsBoxName);
  }
}

Box<FocusSessionRecord>? tryGetSessionsBox() {
  if (!Hive.isBoxOpen(sessionsBoxName)) return null;
  return Hive.box<FocusSessionRecord>(sessionsBoxName);
}

