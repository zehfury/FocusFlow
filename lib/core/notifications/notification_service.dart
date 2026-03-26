import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/timer/application/pomodoro_state.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int pomodoroEndNotificationId = 1001;
  static const String _channelId = 'pomodoro_timer';
  static const String _channelName = 'Pomodoro timer';
  static const String _channelDescription = 'Alerts when Focus/Break ends';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: initSettings);

    // Permissions
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: false, sound: true);

    _initialized = true;
  }

  Future<void> cancelPomodoroEnd() async {
    if (!_initialized) return;
    await _plugin.cancel(id: pomodoroEndNotificationId);
  }

  Future<void> schedulePomodoroEnd({
    required DateTime endsAt,
    required PomodoroMode mode,
  }) async {
    if (!_initialized) return;

    final (title, body) = _endCopy(mode);

    // Schedule using timezone-aware API so it can fire while app is closed.
    final tzDateTime = tz.TZDateTime.from(endsAt, tz.local);

    await _plugin.zonedSchedule(
      id: pomodoroEndNotificationId,
      title: title,
      body: body,
      scheduledDate: tzDateTime,
      notificationDetails: _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  Future<void> showPomodoroEndedNow(PomodoroMode mode) async {
    if (!_initialized) return;

    final (title, body) = _endCopy(mode);
    await _plugin.show(
      id: pomodoroEndNotificationId,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );
  }

  (String, String) _endCopy(PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.focus => ('Focus complete', 'Time for a break.'),
      PomodoroMode.breakMode => ('Break complete', 'Back to focus.'),
    };
  }
}

