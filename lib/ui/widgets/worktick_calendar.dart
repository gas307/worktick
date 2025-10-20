import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/models/work_log.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/i18n_utils.dart';

class WorkTickCalendar extends StatefulWidget {
  final List<WorkLog> logs;
  const WorkTickCalendar({super.key, required this.logs});

  @override
  State<WorkTickCalendar> createState() => _WorkTickCalendarState();
}

class _WorkTickCalendarState extends State<WorkTickCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, int> _minutesMap() {
    final map = <DateTime, int>{};
    for (final l in widget.logs) {
      final key = DateTime(l.start.year, l.start.month, l.start.day);
      map[key] = (map[key] ?? 0) + l.minutes;
    }
    return map;
  }

  int _monthTotalMinutes(DateTime month) {
    int sum = 0;
    for (final l in widget.logs) {
      if (l.start.year == month.year && l.start.month == month.month) {
        sum += l.minutes;
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(2020, 1, 1);
    final lastDay = DateTime(2100, 12, 31);
    final locale = context.locale.toString();

    final minutesByDay = _minutesMap();
    final monthTitle =
        toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(_focusedDay)) ?? '';
    final monthMinutes = _monthTotalMinutes(_focusedDay);

    return Column(
      children: [
        // Nagłówek miesiąca + nawigacja
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Poprzedni miesiąc',
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                    _selectedDay = null;
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  monthTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Następny miesiąc',
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                    _selectedDay = null;
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),

        // Podsumowanie miesiąca — globalny format X h Y min
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '${'app.total'.tr()}: ${formatDurationHM(monthMinutes)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),

        // Kalendarz: stałe kwadratowe kafelki, przewijanie w pionie gdy brak miejsca
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tile = constraints.maxWidth / 7; // stała szerokość kolumny
              const daysOfWeekHeight = 32.0;
              final calendarHeight = daysOfWeekHeight + tile * 6;

              return SingleChildScrollView(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: calendarHeight,
                  child: TableCalendar(
                    locale: locale,
                    firstDay: firstDay,
                    lastDay: lastDay,
                    focusedDay: _focusedDay,
                    headerVisible: false,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    sixWeekMonthsEnforced: true,
                    daysOfWeekHeight: daysOfWeekHeight,
                    rowHeight: tile,

                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = DateTime(focusedDay.year, focusedDay.month, 1);
                      });
                      _showDaySheet(selectedDay, minutesByDay); // ⬅️ metoda tej klasy
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = DateTime(focusedDay.year, focusedDay.month, 1);
                        _selectedDay = null;
                      });
                    },

                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: true,
                      cellMargin: EdgeInsets.zero,
                      isTodayHighlighted: false,
                    ),

                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) =>
                          _dayCell(context, day, minutesByDay),
                      todayBuilder: (context, day, _) =>
                          _dayCell(context, day, minutesByDay, isToday: true),
                      selectedBuilder: (context, day, _) =>
                          _dayCell(context, day, minutesByDay, isSelected: true),
                      outsideBuilder: (context, day, _) => Opacity(
                        opacity: 0.5,
                        child: _dayCell(context, day, minutesByDay),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dayCell(
    BuildContext context,
    DateTime day,
    Map<DateTime, int> minutesByDay, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final key = DateTime(day.year, day.month, day.day);
    final minutes = minutesByDay[key] ?? 0;
    final scheme = Theme.of(context).colorScheme;

    // mocniejsze wyróżnienie – skalowanie do 10h
    final intensity = (minutes / 600).clamp(0.0, 1.0); // 0..1
    // tło w kolorze primary z wyraźną alfą
    final Color? bgColor = minutes > 0
        ? scheme.primary.withOpacity(0.12 + 0.35 * intensity) // ~0.12..0.47
        : null;

    final borderColor = isSelected
        ? scheme.primary
        : isToday
            ? scheme.primary
            : scheme.outlineVariant;
    final borderWidth = (isSelected || isToday) ? 2.0 : 1.0;

    // badge tła (lekko ciemniejsze od tła dla czytelności)
    final badgeColor = minutes > 0
        ? scheme.onPrimary.withOpacity(0.06)
        : scheme.surfaceVariant.withOpacity(0.5);

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            // dzień w lewym górnym
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${day.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),

            // badge z czasem w prawym dolnym
            if (minutes > 0)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: scheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    formatDurationHM(minutes),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  // === Bottom sheet z podglądem dnia ===
  void _showDaySheet(DateTime day, Map<DateTime, int> minutesByDay) {
    final locale = context.locale.toString();
    final dayKey = DateTime(day.year, day.month, day.day);

    // Zbierz logi z danego dnia (posortowane)
    final logs = widget.logs
        .where((l) =>
            l.start.year == day.year &&
            l.start.month == day.month &&
            l.start.day == day.day)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final total = minutesByDay[dayKey] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nagłówek: data + suma
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat.yMMMMEEEEd(locale).format(day),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${'app.total'.tr()}: ${formatDurationHM(total)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Lista logów albo informacja o braku
              if (logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'app.noLogsYet'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final l = logs[i];
                      final range = formatTimeRange(l.start, l.end);
                      final dur = formatDurationHM(l.minutes);
                      final subtitle = [
                        trWorkType(l.workType),
                        if (l.note != null && l.note!.isNotEmpty) l.note!,
                      ].join(' · ');

                      return ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text('$range  ·  $dur'),
                        subtitle: subtitle.isEmpty ? null : Text(subtitle),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
