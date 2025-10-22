import 'dart:io';
import 'dart:convert'; // dla `utf8`
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/report_models.dart';
import '../../data/models/work_log.dart';

class CsvUtils {
  // ===== helpers =====
  static String _hm(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final mm = m.toString().padLeft(2, '0');
    return '$h:$mm'; // HH:MM dla Excela
  }

  static String _isoDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _isoDateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '${_isoDate(d)} $hh:$mm:$ss';
  }

  static const String _bom = '\uFEFF'; // UTF-8 BOM dla Excela na Windows

  static const ListToCsvConverter _conv = ListToCsvConverter(
    fieldDelimiter: ';', // polski Excel lubi średniki
    textDelimiter: '"',
    eol: '\r\n',
  );

  // ===== USER MONTHLY REPORT =====
  static Future<String> saveMonthlyReportCsv(
    MonthlyReport report, {
    List<WorkLog> logs = const [],
    String? userDisplay,
    String? userEmail,
  }) async {
    final rows = <List<dynamic>>[];

    // ✅ Użytkownik: preferuj e-mail, potem displayName, na końcu UID
    final String who = (userEmail != null && userEmail.isNotEmpty)
        ? userEmail
        : (userDisplay?.isNotEmpty ?? false)
            ? userDisplay!
            : report.uid;

    // METADANE
    rows.add(['Raport', 'Raport miesięczny użytkownika']);
    rows.add(['Użytkownik', who]);
    // Jeśli mamy i e-mail, i czytelną nazwę – dodaj osobno "Nazwa"
    if ((userDisplay?.isNotEmpty ?? false) && userDisplay != who) {
      rows.add(['Nazwa', userDisplay]);
    }
    rows.add(['Okres', '${report.year}-${report.month.toString().padLeft(2, '0')}']);
    rows.add(['Wygenerowano', _isoDateTime(DateTime.now())]);
    rows.add([]);

    // PODSUMOWANIE
    rows.add(['Podsumowanie']);
    rows.add(['Suma minut', 'Czas (HH:MM)']);
    rows.add([report.minutesTotal, _hm(report.minutesTotal)]);
    rows.add([]);

    // DZIENNIE
    rows.add(['Dziennie']);
    rows.add(['Data', 'Suma minut', 'Czas (HH:MM)']);
    for (final d in report.byDay) {
      rows.add([_isoDate(d.day), d.minutesTotal, _hm(d.minutesTotal)]);
    }
    rows.add([]);

    // WPISY (pełne)
    if (logs.isNotEmpty) {
      final month = report.month;
      final year = report.year;
      final monthLogs = logs
          .where((l) => l.start.year == year && l.start.month == month)
          .toList()
        ..sort((a, b) => a.start.compareTo(b.start));

      rows.add(['Wpisy']);
      rows.add(['Data', 'Start', 'Koniec', 'Minuty', 'Czas (HH:MM)', 'Typ', 'Notatka', 'ID']);
      for (final l in monthLogs) {
        rows.add([
          _isoDate(l.start),
          l.start.toIso8601String().substring(11, 16), // HH:MM
          l.end.toIso8601String().substring(11, 16),
          l.minutes,
          _hm(l.minutes),
          l.workType,
          l.note ?? '',
          l.id ?? '',
        ]);
      }
      rows.add([]);
    }

    final csv = _bom + _conv.convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/worktick_report_${report.uid}_${report.year}_${report.month}.csv');
    await file.writeAsString(csv, encoding: utf8);
    return file.path;
  }

  // ===== ORG (ALL USERS) MONTHLY REPORT =====
  static Future<String> saveOrgMonthlyReportCsv(OrgMonthlyReport report) async {
    final rows = <List<dynamic>>[];

    // METADANE
    rows.add(['Raport', 'Raport miesięczny – wszyscy użytkownicy']);
    rows.add(['Okres', '${report.year}-${report.month.toString().padLeft(2, '0')}']);
    rows.add(['Wygenerowano', _isoDateTime(DateTime.now())]);
    rows.add([]);

    // TABELA UŻYTKOWNIKÓW
    rows.add(['Użytkownicy']);
    rows.add(['#', 'Użytkownik', 'E-mail', 'UID', 'Suma minut', 'Czas (HH:MM)']);
    for (var i = 0; i < report.users.length; i++) {
      final u = report.users[i];
      final display = (u.displayName?.isNotEmpty ?? false)
          ? u.displayName!
          : (u.email?.isNotEmpty ?? false)
              ? u.email!
              : u.uid;
      rows.add([
        i + 1,
        display,
        u.email ?? '',
        u.uid,
        u.totalMinutes,
        _hm(u.totalMinutes),
      ]);
    }
    rows.add([]);

    final csv = _bom + _conv.convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/worktick_org_report_${report.year}_${report.month}.csv');
    await file.writeAsString(csv, encoding: utf8);
    return file.path;
  }
}
