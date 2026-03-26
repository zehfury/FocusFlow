import 'package:hive/hive.dart';

import 'pomodoro_state.dart';

/// Hive box name for the persisted Pomodoro state.
const pomodoroBoxName = 'pomodoro_box';

/// Single record key inside the [pomodoroBoxName].
const pomodoroRecordKey = 'pomodoro_state';

/// Lightweight persisted model for the Pomodoro timer.
///
/// We store:
/// - mode + status
/// - remaining (best-effort)
/// - `endAtEpochMs` when running (preferred for accurate restore)
class PomodoroPersistedState {
  const PomodoroPersistedState({
    required this.modeIndex,
    required this.statusIndex,
    required this.remainingMs,
    required this.endAtEpochMs,
  });

  // Enums are persisted as indexes to keep storage small + stable.
  final int modeIndex; // 0 focus, 1 break
  final int statusIndex; // 0 idle, 1 running, 2 paused

  /// Remaining in milliseconds at the time of persistence.
  final int remainingMs;

  /// Epoch millis for the end of the current mode when running.
  /// -1 means "not scheduled" (e.g. paused/idle).
  final int endAtEpochMs;
}

class PomodoroPersistedStateAdapter
    extends TypeAdapter<PomodoroPersistedState> {
  @override
  final int typeId = 42;

  @override
  PomodoroPersistedState read(BinaryReader reader) {
    final modeIndex = reader.readInt();
    final statusIndex = reader.readInt();
    final remainingMs = reader.readInt();
    final endAtEpochMs = reader.readInt();
    return PomodoroPersistedState(
      modeIndex: modeIndex,
      statusIndex: statusIndex,
      remainingMs: remainingMs,
      endAtEpochMs: endAtEpochMs,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroPersistedState obj) {
    writer.writeInt(obj.modeIndex);
    writer.writeInt(obj.statusIndex);
    writer.writeInt(obj.remainingMs);
    writer.writeInt(obj.endAtEpochMs);
  }
}

Future<void> initPomodoroPersistence() async {
  // Register adapter once.
  if (!Hive.isAdapterRegistered(PomodoroPersistedStateAdapter().typeId)) {
    Hive.registerAdapter(PomodoroPersistedStateAdapter());
  }

  if (!Hive.isBoxOpen(pomodoroBoxName)) {
    await Hive.openBox<PomodoroPersistedState>(pomodoroBoxName);
  }
}

PomodoroMode persistedModeFromIndex(int modeIndex) {
  return modeIndex == 1 ? PomodoroMode.breakMode : PomodoroMode.focus;
}

PomodoroStatus persistedStatusFromIndex(int statusIndex) {
  switch (statusIndex) {
    case 2:
      return PomodoroStatus.paused;
    case 1:
      return PomodoroStatus.running;
    default:
      return PomodoroStatus.idle;
  }
}

int modeIndexFromPersisted(PomodoroMode mode) =>
    mode == PomodoroMode.breakMode ? 1 : 0;

int statusIndexFromPersisted(PomodoroStatus status) {
  switch (status) {
    case PomodoroStatus.paused:
      return 2;
    case PomodoroStatus.running:
      return 1;
    case PomodoroStatus.idle:
      return 0;
  }
}

