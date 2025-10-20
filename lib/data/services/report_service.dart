import '../models/report_models.dart';
import '../models/work_log.dart';

class ReportService {
  MonthlyReport buildMonthlyReport({
    required String uid,
    required int year,
    required int month,
    required List<WorkLog> logs,
  }) {
    final monthLogs = logs
        .where((l) => l.start.year == year && l.start.month == month)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final Map<DateTime, List<WorkLog>> byDay = {};
    for (final l in monthLogs) {
      final d = DateTime(l.start.year, l.start.month, l.start.day);
      (byDay[d] ??= []).add(l);
    }

    final List<DaySummary> daySummaries = [];
    final Map<String, int> monthByType = {'office': 0, 'remote': 0, 'field': 0};
    int total = 0;

    byDay.forEach((day, dayLogs) {
      int dayTotal = 0;
      final Map<String, int> byType = {'office': 0, 'remote': 0, 'field': 0};
      for (final l in dayLogs) {
        dayTotal += l.minutes;
        byType[l.workType] = (byType[l.workType] ?? 0) + l.minutes;
        monthByType[l.workType] = (monthByType[l.workType] ?? 0) + l.minutes;
      }
      total += dayTotal;
      daySummaries.add(DaySummary(
        day: day,
        minutesTotal: dayTotal,
        minutesByWorkType: byType,
      ));
    });

    daySummaries.sort((a, b) => a.day.compareTo(b.day));

    final byWorkType = monthByType.entries
        .map((e) => WorkTypeSummary(workType: e.key, minutes: e.value))
        .toList();

    return MonthlyReport(
      uid: uid,
      year: year,
      month: month,
      minutesTotal: total,
      byWorkType: byWorkType,
      byDay: daySummaries,
    );
  }
}

// ===== RAPORT ZBIORCZY ORGANIZACJI =====

class OrgReportService {
  OrgMonthlyReport buildOrgMonthlyReport({
    required int year,
    required int month,
    required Map<String, ({String? displayName, String? email})> users,
    required Map<String, List<WorkLog>> logsByUid,
  }) {
    int grandTotal = 0;
    final Map<String, int> orgByType = {'office': 0, 'remote': 0, 'field': 0};
    final List<OrgUserRow> rows = [];

    for (final entry in logsByUid.entries) {
      final uid = entry.key;
      final uLogs = entry.value;

      int userTotal = 0;
      final Map<String, int> byType = {'office': 0, 'remote': 0, 'field': 0};

      for (final l in uLogs) {
        userTotal += l.minutes;
        byType[l.workType] = (byType[l.workType] ?? 0) + l.minutes;
      }

      grandTotal += userTotal;
      orgByType['office'] = (orgByType['office'] ?? 0) + (byType['office'] ?? 0);
      orgByType['remote'] = (orgByType['remote'] ?? 0) + (byType['remote'] ?? 0);
      orgByType['field']  = (orgByType['field']  ?? 0) + (byType['field']  ?? 0);

      final info = users[uid] ?? (displayName: null, email: null);
      rows.add(OrgUserRow(
        uid: uid,
        displayName: info.displayName,
        email: info.email,
        totalMinutes: userTotal,
        minutesByWorkType: byType,
      ));
    }

    rows.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));

    return OrgMonthlyReport(
      year: year,
      month: month,
      totalMinutes: grandTotal,
      minutesByWorkType: orgByType,
      users: rows,
    );
  }
}
