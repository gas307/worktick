import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/report_models.dart';

class CsvUtils {
  static Future<String> saveMonthlyReportCsv(MonthlyReport report) async {
    final rows = <List<dynamic>>[];

    rows.add(['Monthly Report', '${report.year}-${report.month.toString().padLeft(2, '0')}']);
    rows.add(['User UID', report.uid]);
    rows.add([]);
    rows.add(['Total minutes', report.minutesTotal]);
    rows.add([]);
    rows.add(['By Work Type', 'minutes']);
    for (final wt in report.byWorkType) {
      rows.add([wt.workType, wt.minutes]);
    }
    rows.add([]);
    rows.add(['Day', 'total_minutes', 'office', 'remote', 'field']);
    for (final d in report.byDay) {
      rows.add([
        '${d.day.year}-${d.day.month.toString().padLeft(2, '0')}-${d.day.day.toString().padLeft(2, '0')}',
        d.minutesTotal,
        d.minutesByWorkType['office'] ?? 0,
        d.minutesByWorkType['remote'] ?? 0,
        d.minutesByWorkType['field'] ?? 0,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/worktick_report_${report.uid}_${report.year}_${report.month}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  // ⬇⬇⬇ DODANE: CSV dla raportu zbiorczego
  static Future<String> saveOrgMonthlyReportCsv(OrgMonthlyReport report) async {
    final rows = <List<dynamic>>[];

    rows.add(['Org Monthly Report', '${report.year}-${report.month.toString().padLeft(2, '0')}']);
    rows.add(['Total minutes', report.totalMinutes]);
    rows.add(['By Work Type']);
    rows.add(['office', report.minutesByWorkType['office'] ?? 0]);
    rows.add(['remote', report.minutesByWorkType['remote'] ?? 0]);
    rows.add(['field',  report.minutesByWorkType['field']  ?? 0]);
    rows.add([]);

    rows.add(['UID','Display Name','Email','Total','office','remote','field']);
    for (final u in report.users) {
      rows.add([
        u.uid,
        u.displayName ?? '',
        u.email ?? '',
        u.totalMinutes,
        u.minutesByWorkType['office'] ?? 0,
        u.minutesByWorkType['remote'] ?? 0,
        u.minutesByWorkType['field']  ?? 0,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/worktick_org_report_${report.year}_${report.month}.csv');
    await file.writeAsString(csv);
    return file.path;
  }
}
