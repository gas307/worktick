import 'package:easy_localization/easy_localization.dart';

/// Zwraca sformatowany czas w stylu `2 h 15 min`
/// W zależności od potrzeb można dodać `compact = true`, żeby dało np. `2h 15m`
String formatDurationHM(int minutes, {bool compact = false}) {
  final h = minutes ~/ 60;
  final m = minutes % 60;

  final hLabel = compact ? 'h' : 'app.hoursShort'.tr(); // „h” lub tłumaczenie
  final mLabel = compact ? 'm' : 'app.minutes'.tr();     // „min” lub tłumaczenie

  if (minutes <= 0) return '0 $hLabel';
  if (m == 0) return '$h $hLabel';
  if (h == 0) return '$m $mLabel';
  return '$h $hLabel $m $mLabel';
}

/// Format przedziału godzin: `07:30 → 15:45`
String formatTimeRange(DateTime start, DateTime end) {
  final s = DateFormat.Hm().format(start);
  final e = DateFormat.Hm().format(end);
  return '$s → $e';
}
