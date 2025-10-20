class DaySummary {
  final DateTime day;
  final int minutesTotal;
  final Map<String, int> minutesByWorkType; // office/remote/field

  DaySummary({
    required this.day,
    required this.minutesTotal,
    required this.minutesByWorkType,
  });
}

class WorkTypeSummary {
  final String workType; // 'office'|'remote'|'field'
  final int minutes;

  WorkTypeSummary({required this.workType, required this.minutes});
}

class MonthlyReport {
  final String uid;
  final int year;
  final int month; // 1..12
  final int minutesTotal;
  final List<WorkTypeSummary> byWorkType;
  final List<DaySummary> byDay;

  MonthlyReport({
    required this.uid,
    required this.year,
    required this.month,
    required this.minutesTotal,
    required this.byWorkType,
    required this.byDay,
  });
}

// ===== ZBIORCZY RAPORT ORGANIZACJI =====

class OrgUserRow {
  final String uid;
  final String? displayName;
  final String? email;
  final int totalMinutes;
  final Map<String, int> minutesByWorkType; // office/remote/field

  OrgUserRow({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.totalMinutes,
    required this.minutesByWorkType,
  });
}

class OrgMonthlyReport {
  final int year;
  final int month;
  final int totalMinutes;
  final Map<String, int> minutesByWorkType; // office/remote/field
  final List<OrgUserRow> users;

  OrgMonthlyReport({
    required this.year,
    required this.month,
    required this.totalMinutes,
    required this.minutesByWorkType,
    required this.users,
  });
}
