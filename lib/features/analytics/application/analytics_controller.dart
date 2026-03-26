import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/analytics_persistence.dart';
import '../data/analytics_repository.dart';
import '../data/focus_session_record.dart';

class AnalyticsState {
  const AnalyticsState({
    required this.isReady,
    required this.totalFocusToday,
    required this.completedFocusSessionsToday,
    required this.totalSessionsAllTime,
  });

  final bool isReady;
  final Duration totalFocusToday;
  final int completedFocusSessionsToday;
  final int totalSessionsAllTime;
}

class AnalyticsController extends Notifier<AnalyticsState> {
  AnalyticsRepository? _repo;
  StreamSubscription? _sub;

  @override
  AnalyticsState build() {
    ref.onDispose(() => unawaited(_sub?.cancel()));

    final box = tryGetSessionsBox();
    if (box == null) {
      return const AnalyticsState(
        isReady: false,
        totalFocusToday: Duration.zero,
        completedFocusSessionsToday: 0,
        totalSessionsAllTime: 0,
      );
    }

    _repo = AnalyticsRepository(box);
    _sub = _repo!.watch().listen((_) => _recompute());

    return _recompute();
  }

  AnalyticsState _recompute() {
    final repo = _repo;
    if (repo == null) {
      return const AnalyticsState(
        isReady: false,
        totalFocusToday: Duration.zero,
        completedFocusSessionsToday: 0,
        totalSessionsAllTime: 0,
      );
    }

    final sessions = repo.getAll();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startMs = startOfToday.millisecondsSinceEpoch;

    var focusMsToday = 0;
    var focusCountToday = 0;

    for (final s in sessions) {
      if (s.endedAtEpochMs < startMs) break;
      if (s.kind == SessionKind.focus) {
        focusMsToday += s.durationMs;
        focusCountToday += 1;
      }
    }

    final next = AnalyticsState(
      isReady: true,
      totalFocusToday: Duration(milliseconds: focusMsToday),
      completedFocusSessionsToday: focusCountToday,
      totalSessionsAllTime: sessions.length,
    );

    state = next;
    return next;
  }
}

final analyticsProvider =
    NotifierProvider<AnalyticsController, AnalyticsState>(AnalyticsController.new);

