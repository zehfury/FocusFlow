enum SessionKind {
  focus,
  breakMode,
}

class FocusSessionRecord {
  const FocusSessionRecord({
    required this.kindIndex,
    required this.durationMs,
    required this.endedAtEpochMs,
  });

  /// 0 focus, 1 break
  final int kindIndex;

  final int durationMs;
  final int endedAtEpochMs;

  SessionKind get kind => kindIndex == 1 ? SessionKind.breakMode : SessionKind.focus;

  DateTime get endedAt => DateTime.fromMillisecondsSinceEpoch(endedAtEpochMs);

  Duration get duration => Duration(milliseconds: durationMs);
}

