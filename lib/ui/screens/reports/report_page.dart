import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/work_log.dart';
import '../../../data/models/report_models.dart';
import '../../../data/services/report_service.dart';
import '../../../data/repositories/worklog_repository.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/i18n_utils.dart';
import 'dart:io';
import '../../../core/utils/csv_utils.dart';

class ReportPage extends StatefulWidget {
  final String uid;        // raport dla tego użytkownika
  final String? title;     // opcjonalnie nazwa/ e-mail do wyświetlenia
  const ReportPage({super.key, required this.uid, this.title});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _workRepo = WorklogRepository();
  final _service = ReportService();

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
  }

  void _nextMonth() {
    setState(() => _month = DateTime(_month.year, _month.month + 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    final y = _month.year;
    final m = _month.month;
    final header = toBeginningOfSentenceCase(DateFormat.yMMMM(context.locale.toString()).format(_month)) ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pasek tytułu + nawigacja miesięcy + eksport
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Text(
                  widget.title == null ? header : '$header · ${widget.title}',
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: StreamBuilder<List<WorkLog>>(
            stream: _workRepo.watchLogsForMonth(widget.uid, y, m),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final logs = snap.data!;
              final report = _service.buildMonthlyReport(
                uid: widget.uid,
                year: y,
                month: m,
                logs: logs,
              );

              final total = formatDurationHM(report.minutesTotal);

              return Column(
                children: [
                  // Sumy
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      children: [
                        Text('${'app.total'.tr()}: $total',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Spacer(),
                        FilledButton.icon(
                          icon: const Icon(Icons.file_download),
                          label: const Text('CSV'),
                          onPressed: () async {
                            final path = await CsvUtils.saveMonthlyReportCsv(report);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Zapisano CSV: $path')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.ios_share),
                          label: Text('app.share'.tr()),
                          onPressed: () async {
                            final path = await CsvUtils.saveMonthlyReportCsv(report);
                            await Share.shareXFiles([XFile(path)], text: 'WorkTick ${report.year}-${report.month.toString().padLeft(2, '0')}');
                          },
                        )
                      ],
                    ),
                  ),

                  // Podział na typy pracy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: report.byWorkType.map((w) {
                        return Chip(
                          label: Text('${trWorkType(w.workType)}: ${formatDurationHM(w.minutes)}'),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),

                  // Lista dni
                  Expanded(
                    child: report.byDay.isEmpty
                        ? Center(child: Text('app.noLogsYet'.tr()))
                        : ListView.separated(
                            itemCount: report.byDay.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final d = report.byDay[i];
                              final dateLabel = DateFormat.yMMMMEEEEd(context.locale.toString()).format(d.day);
                              final totalDay = formatDurationHM(d.minutesTotal);

                              final types = ['office','remote','field']
                                  .map((t) => '${trWorkType(t)}: ${formatDurationHM(d.minutesByWorkType[t] ?? 0)}')
                                  .join(' · ');

                              return ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: Text('$dateLabel  ·  $totalDay'),
                                subtitle: Text(types),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
