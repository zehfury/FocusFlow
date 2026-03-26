import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/notes/presentation/notes_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/timer/presentation/timer_screen.dart';
import 'app_shell.dart';
import 'route_transitions.dart';

/// Global router for the app.
///
/// Uses a [StatefulShellRoute] so each bottom tab can keep its own navigation
/// stack (e.g. Timer details, Notes editor, Tasks detail) without losing state
/// when switching tabs.
final GoRouter appRouter = GoRouter(
  initialLocation: '/timer',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/timer',
              name: 'timer',
              pageBuilder: (context, state) => RouteTransitions.none(
                state: state,
                child: const TimerScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notes',
              name: 'notes',
              pageBuilder: (context, state) => RouteTransitions.none(
                state: state,
                child: const NotesScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'note_new',
                  pageBuilder: (context, state) => RouteTransitions.fadeSlide(
                    state: state,
                    child: const NoteEditorScreen(),
                  ),
                ),
                GoRoute(
                  path: 'edit/:key',
                  name: 'note_edit',
                  pageBuilder: (context, state) {
                    final keyParam = state.pathParameters['key'];
                    final key = int.tryParse(keyParam ?? '');
                    return RouteTransitions.fadeSlide(
                      state: state,
                      child: NoteEditorScreen(noteKey: key),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              pageBuilder: (context, state) => RouteTransitions.none(
                state: state,
                child: const TasksScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'analytics',
                  name: 'analytics',
                  pageBuilder: (context, state) => RouteTransitions.fadeSlide(
                    state: state,
                    child: const AnalyticsScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text(
          state.error?.toString() ?? 'Unknown navigation error',
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
);

