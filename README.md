# FocusFlow

FocusFlow is a Flutter productivity app with a Pomodoro timer, notes, and local analytics.

## Features

- Pomodoro timer (Focus/Break) with start, pause, reset, and skip
- Local notifications when sessions end
- Notes feature (add, edit, delete) stored locally
- Analytics screen for focus time and completed sessions
- Dark-mode first, clean and responsive UI

## Tech Stack

- Flutter
- Riverpod (state management)
- Hive (local storage)
- go_router (navigation)
- flutter_local_notifications (alerts)

## Project Structure

```text
lib/
  core/       # app-wide theme, notifications, shared infrastructure
  features/   # feature-first modules (timer, notes, analytics, tasks)
  shared/     # reusable widgets and utilities
  app/        # router and app shell
```

## Run Locally

1. Install Flutter SDK
2. Get packages:
   - `flutter pub get`
3. Run app:
   - `flutter run`

## Build APK

- `flutter build apk`

## Notes

- Data is stored locally on device (Hive).
- Notifications require Android notification permissions.
