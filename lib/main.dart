import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/router/app_router.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/data/analytics_persistence.dart';
import 'features/timer/application/pomodoro_controller.dart';
import 'features/timer/application/pomodoro_persistence.dart';
import 'features/notes/data/notes_persistence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initPomodoroPersistence();
  await initNotesPersistence();
  await initAnalyticsPersistence();
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      child: _PomodoroLifecycleSaver(
        child: const FocusFlowApp(),
      ),
    ),
  );
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'FocusFlow',
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}

class _PomodoroLifecycleSaver extends ConsumerStatefulWidget {
  const _PomodoroLifecycleSaver({required this.child});

  final Widget child;

  @override
  ConsumerState<_PomodoroLifecycleSaver> createState() =>
      __PomodoroLifecycleSaverState();
}

class __PomodoroLifecycleSaverState
    extends ConsumerState<_PomodoroLifecycleSaver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(
        ref.read(pomodoroProvider.notifier).persistNow(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
