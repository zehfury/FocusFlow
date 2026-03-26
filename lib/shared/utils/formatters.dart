import 'package:intl/intl.dart';

sealed class Formatters {
  Formatters._();

  static String formatDurationShort(Duration d) {
    final totalMinutes = d.inMinutes;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h <= 0) return '${m}m';
    return '${h}h ${m}m';
  }

  static String formatMMSS(Duration d) {
    final totalSeconds = d.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static DateFormat noteTimestampFormatter() => DateFormat.yMMMd().add_jm();
}

