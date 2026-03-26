enum PomodoroMode {
  focus,
  breakMode,
}

enum PomodoroStatus {
  idle,
  running,
  paused,
}

class PomodoroState {
  const PomodoroState({
    required this.mode,
    required this.status,
    required this.remaining,
    required this.total,
  });

  factory PomodoroState.initial({
    required Duration focusDuration,
    required Duration breakDuration,
  }) {
    return PomodoroState(
      mode: PomodoroMode.focus,
      status: PomodoroStatus.idle,
      remaining: focusDuration,
      total: focusDuration,
    );
  }

  final PomodoroMode mode;
  final PomodoroStatus status;
  final Duration remaining;
  final Duration total;

  double get progress01 {
    final totalMs = total.inMilliseconds;
    if (totalMs <= 0) return 0;
    final remainingMs = remaining.inMilliseconds;
    return (remainingMs / totalMs).clamp(0.0, 1.0);
  }

  Duration get remainingClamped {
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  PomodoroState copyWith({
    PomodoroMode? mode,
    PomodoroStatus? status,
    Duration? remaining,
    Duration? total,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      remaining: remaining ?? this.remaining,
      total: total ?? this.total,
    );
  }
}

