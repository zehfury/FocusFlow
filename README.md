# 🚀 FocusFlow

FocusFlow is a Flutter productivity app with a Pomodoro timer, notes, and local analytics.

---

## ✨ Features

- ⏱️ Pomodoro timer (Focus/Break) with start, pause, reset, and skip  
- 🔔 Local notifications when sessions end  
- 📝 Notes feature (add, edit, delete) stored locally  
- 📊 Analytics screen for focus time and completed sessions  
- 🌙 Dark-mode first, clean and responsive UI  

---

## 🛠️ Tech Stack

- Flutter  
- Riverpod (state management)  
- Hive (local storage)  
- go_router (navigation)  
- flutter_local_notifications (alerts)  

---

## 📂 Project Structure

```text
lib/
  core/       # app-wide theme, notifications, shared infrastructure
  features/   # feature-first modules (timer, notes, analytics, tasks)
  shared/     # reusable widgets and utilities
  app/        # router and app shell
```

## 📱 Preview

<p align="center">
  <img src="https://github.com/zehfury/FocusFlow/blob/main/flutter-8.jpg?raw=true" width="180"/>
  <img src="https://github.com/zehfury/FocusFlow/blob/main/flutter-8.jpg?raw=true" width="180"/>
  <img src="https://github.com/zehfury/FocusFlow/blob/main/flutter-9.jpg?raw=true" width="180"/>
</p>

<p align="center">
  <sub>📊 Dashboard</sub> &nbsp;&nbsp;&nbsp;&nbsp;
  <sub>⏱️ 25 mins Work</sub> &nbsp;&nbsp;&nbsp;&nbsp;
  <sub>☕ 5 mins Break</sub>
</p>

<br>

<p align="center">
  <img src="https://via.placeholder.com/180x360?text=Notes" width="180"/>
  <img src="https://github.com/zehfury/FocusFlow/blob/main/flutter-10.jpg?raw=true" width="180"/>
  <img src="https://github.com/zehfury/FocusFlow/blob/main/flutter-11.jpg?raw=true" width="180"/>
</p>

<p align="center">
  <sub>📝 Notes</sub> &nbsp;&nbsp;&nbsp;&nbsp;
  <sub>➕ New Note</sub> &nbsp;&nbsp;&nbsp;&nbsp;
  <sub>✅ Tasks</sub>
</p>

---

## ▶️ Run Locally

Install Flutter SDK

Get packages:

flutter pub get

Run app:

flutter run
📦 Build APK
flutter build apk
📝 Notes
Data is stored locally on device (Hive)
Notifications require Android notification permissions
