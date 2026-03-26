import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/notifications/notification_service.dart';
import '../../analytics/data/analytics_persistence.dart';
import '../../analytics/data/analytics_repository.dart';
import '../../analytics/data/focus_session_record.dart';
import 'pomodoro_state.dart';
import 'pomodoro_persistence.dart';

/// Riverpod controller for the Pomodoro timer.
///
/// Internal ticking is based on a stable `endAt` timestamp to keep the
/// countdown accurate (avoids drift from long-running periodic timers).
class PomodoroController extends Notifier<PomodoroState> {
  static const Duration focusDuration = Duration(minutes: 25);
  static const Duration breakDuration = Duration(minutes: 5);

  static const Duration _tickInterval = Duration(milliseconds: 250);

  Timer? _ticker;
  DateTime? _endAt;

  Box<PomodoroPersistedState>? _box;
  NotificationService? _notifications;
  AnalyticsRepository? _analyticsRepo;

  Duration get _currentModeTotal =>
      state.mode == PomodoroMode.focus ? focusDuration : breakDuration;

  Duration _durationForMode(PomodoroMode mode) =>
      mode == PomodoroMode.focus ? focusDuration : breakDuration;

  PomodoroMode _toggleMode(PomodoroMode mode) =>
      mode == PomodoroMode.focus ? PomodoroMode.breakMode : PomodoroMode.focus;

  @override
  PomodoroState build() {
    ref.onDispose(() {
      _ticker?.cancel();
      _ticker = null;
      _endAt = null;
      // Best-effort persistence on provider disposal.
      unawaited(persistNow());
    });

    _notifications = NotificationService.instance;
    final sessionsBox = tryGetSessionsBox();
    if (sessionsBox != null) {
      _analyticsRepo = AnalyticsRepository(sessionsBox);
    }

    if (!Hive.isBoxOpen(pomodoroBoxName)) {
      return PomodoroState.initial(
        focusDuration: focusDuration,
        breakDuration: breakDuration,
      );
    }

    _box = Hive.box<PomodoroPersistedState>(pomodoroBoxName);
    final persisted = _box!.get(pomodoroRecordKey);

    if (persisted == null) {
      return PomodoroState.initial(
        focusDuration: focusDuration,
        breakDuration: breakDuration,
      );
    }

    final restored = _restoreFromPersisted(persisted);

    if (restored.status == PomodoroStatus.running) {
      _startTicker();
    }

    return restored;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  Duration _remainingFromEndAt(DateTime now) {
    final endAt = _endAt;
    if (endAt == null) return state.remaining;
    return endAt.difference(now);
  }

  void _onTick() {
    final now = DateTime.now();
    if (_endAt == null) return;

    final remaining = _remainingFromEndAt(now);
    if (remaining <= Duration.zero) {
      _completeSessionAndAdvance(now);
      return;
    }

    state = state.copyWith(
      status: PomodoroStatus.running,
      remaining: remaining,
      total: _currentModeTotal,
    );
  }

  void _completeSessionAndAdvance(DateTime now) {
    final endedMode = state.mode;
    final nextMode = _toggleMode(state.mode);
    final nextTotal = _durationForMode(nextMode);

    _ticker?.cancel();
    _ticker = null;
    _endAt = null;

    unawaited(_notifications?.cancelPomodoroEnd() ?? Future.value());
    unawaited(_notifications?.showPomodoroEndedNow(endedMode) ?? Future.value());

    // Track completed sessions locally (analytics).
    if (endedMode == PomodoroMode.focus) {
      final endedAt = now.millisecondsSinceEpoch;
      unawaited(
        _analyticsRepo?.addSession(
              FocusSessionRecord(
                kindIndex: 0,
                durationMs: focusDuration.inMilliseconds,
                endedAtEpochMs: endedAt,
              ),
            ) ??
            Future.value(),
      );
    }

    // Do NOT auto-start the next mode. Move to the next mode and pause.
    state = PomodoroState(
      mode: nextMode,
      status: PomodoroStatus.paused,
      remaining: nextTotal,
      total: nextTotal,
    );

    unawaited(persistNow());
  }

  void start() {
    if (state.status == PomodoroStatus.running) return;

    final now = DateTime.now();

    // If the user taps start exactly at the end of a cycle (remaining == 0),
    // advance to the next mode immediately rather than waiting for the next tick.
    if (state.remainingClamped == Duration.zero) {
      final nextMode = state.mode == PomodoroMode.focus
          ? PomodoroMode.breakMode
          : PomodoroMode.focus;
      final nextTotal = _durationForMode(nextMode);
      _endAt = now.add(nextTotal);
      state = PomodoroState(
        mode: nextMode,
        status: PomodoroStatus.running,
        remaining: nextTotal,
        total: nextTotal,
      );
      _startTicker();
      unawaited(
        _notifications?.schedulePomodoroEnd(endsAt: _endAt!, mode: nextMode) ??
            Future.value(),
      );
      unawaited(persistNow());
      return;
    }

    if (_endAt == null) {
      // Starting from idle.
      _endAt = now.add(state.remainingClamped);
    } else {
      // Resuming from paused: _endAt should already reflect the remaining time.
      // Still, re-anchor to `now + remaining` for safety against edge cases.
      _endAt = now.add(state.remainingClamped);
    }

    state = state.copyWith(status: PomodoroStatus.running);
    _startTicker();
    if (_endAt != null) {
      unawaited(
        _notifications?.schedulePomodoroEnd(endsAt: _endAt!, mode: state.mode) ??
            Future.value(),
      );
    }
    unawaited(persistNow());
  }

  /// Skip the current session and move to the next mode (Focus <-> Break).
  ///
  /// This does NOT count as a completed session and leaves the next mode paused,
  /// so the user can choose when to start.
  void skip() {
    final nextMode = _toggleMode(state.mode);
    final nextTotal = _durationForMode(nextMode);

    _ticker?.cancel();
    _ticker = null;
    _endAt = null;

    state = PomodoroState(
      mode: nextMode,
      status: PomodoroStatus.paused,
      remaining: nextTotal,
      total: nextTotal,
    );

    unawaited(_notifications?.cancelPomodoroEnd() ?? Future.value());
    unawaited(persistNow());
  }

  void pause() {
    if (state.status != PomodoroStatus.running) return;

    _ticker?.cancel();
    _ticker = null;

    final now = DateTime.now();
    final remaining = _remainingFromEndAt(now);

    // If the pause occurs right as a cycle completes, move to the next mode
    // but keep it paused (so auto-switch didn't continue running).
    if (remaining <= Duration.zero) {
      final nextMode = _toggleMode(state.mode);
      final nextTotal = _durationForMode(nextMode);
      _endAt = null; // keep paused
      state = PomodoroState(
        mode: nextMode,
        status: PomodoroStatus.paused,
        remaining: nextTotal,
        total: nextTotal,
      );
      unawaited(_notifications?.cancelPomodoroEnd() ?? Future.value());
      unawaited(persistNow());
      return;
    }

    // Paused means the countdown must not keep moving while the app is in
    // background / closed. We persist the computed `remaining` and clear the
    // scheduled end time.
    _endAt = null;

    state = state.copyWith(
      status: PomodoroStatus.paused,
      remaining: remaining,
      total: _currentModeTotal,
    );

    unawaited(_notifications?.cancelPomodoroEnd() ?? Future.value());
    unawaited(persistNow());
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _endAt = null;

    state = PomodoroState.initial(
      focusDuration: focusDuration,
      breakDuration: breakDuration,
    );

    unawaited(_notifications?.cancelPomodoroEnd() ?? Future.value());
    unawaited(persistNow());
  }

  Future<void> persistNow() async {
    final box = _box;
    if (box == null) return;

    final record = PomodoroPersistedState(
      modeIndex: modeIndexFromPersisted(state.mode),
      statusIndex: statusIndexFromPersisted(state.status),
      remainingMs: state.remainingClamped.inMilliseconds,
      endAtEpochMs: _endAt?.millisecondsSinceEpoch ?? -1,
    );

    await box.put(pomodoroRecordKey, record);
  }

  PomodoroState _restoreFromPersisted(PomodoroPersistedState persisted) {
    final now = DateTime.now();

    final restoredMode = persistedModeFromIndex(persisted.modeIndex);
    final restoredStatus = persistedStatusFromIndex(persisted.statusIndex);
    final remaining = Duration(milliseconds: persisted.remainingMs);

    switch (restoredStatus) {
      case PomodoroStatus.paused:
        // Paused state must not drift while the app was closed.
        return PomodoroState(
          mode: restoredMode,
          status: PomodoroStatus.paused,
          remaining: remaining <= Duration.zero ? Duration.zero : remaining,
          total: _durationForMode(restoredMode),
        );
      case PomodoroStatus.running: {
        final endAtEpochMs = persisted.endAtEpochMs;
        if (endAtEpochMs == -1) {
          // Fallback: if we don't have an end timestamp, resume using stored remaining.
          final clampedRemaining = remaining <= Duration.zero
              ? _durationForMode(restoredMode)
              : remaining;
          _endAt = now.add(clampedRemaining);
          return PomodoroState(
            mode: restoredMode,
            status: PomodoroStatus.running,
            remaining: clampedRemaining,
            total: _durationForMode(restoredMode),
          );
        }

        final endAt = DateTime.fromMillisecondsSinceEpoch(endAtEpochMs);
        final remainingFromEnd = endAt.difference(now);

        if (remainingFromEnd > Duration.zero) {
          _endAt = endAt;
          return PomodoroState(
            mode: restoredMode,
            status: PomodoroStatus.running,
            remaining: remainingFromEnd,
            total: _durationForMode(restoredMode),
          );
        }

        // Timer finished while the app was closed. We do NOT auto-run subsequent
        // sessions. Advance a single step to the next mode and pause there.
        final nextMode = _toggleMode(restoredMode);
        final nextTotal = _durationForMode(nextMode);
        _endAt = null;
        return PomodoroState(
          mode: nextMode,
          status: PomodoroStatus.paused,
          remaining: nextTotal,
          total: nextTotal,
        );
      }
      case PomodoroStatus.idle:
        // Treat idle as reset-to-focus for now.
        return PomodoroState.initial(
          focusDuration: focusDuration,
          breakDuration: breakDuration,
        );
    }
  }
}

/// Default 25/5 Pomodoro timer provider.
final pomodoroProvider =
    NotifierProvider<PomodoroController, PomodoroState>(PomodoroController.new);

