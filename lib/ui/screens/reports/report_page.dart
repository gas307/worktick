import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/work_log.dart';
import '../../../data/models/report_models.dart';
import '../../../data/services/report_service.dart';
import '../../../data/repositories/worklog_repository.dart';
import '../../../data/repositories/profile_repository.dart'; // ⬅️ NOWE
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/csv_utils.dart';

class ReportPage extends StatefulWidget {
  final String uid;
  final String? title; // np. displayName z listy
  final String? email; // może być puste z listy – i tak dociągniemy z Firestore

  const ReportPage({
    super.key,
    required this.uid,
    this.title,
    this.email,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _workRepo = WorklogRepository();
  final _service = ReportService();
  final _profiles = ProfileRepository(); // ⬅️ NOWE

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() => setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
  void _nextMonth() => setState(() => _month = DateTime(_month.year, _month.month + 1, 1));

  @override
  Widget build(BuildContext context) {
    final y = _month.year;
    final m = _month.month;
    final header = toBeginningOfSentenceCase(
          DateFormat.yMMMM(context.locale.toString()).format(_month),
        ) ??
        '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nawigacja po miesiącach + tytuł
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
                  // Pasek sumy + eksport
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
                            // ⬇️ NAJPIERW DOŚCIĄGNIJ PROFIL, ŻEBY MIEĆ E-MAIL
                            final p = await _profiles.fetchProfile(widget.uid);
                            final path = await CsvUtils.saveMonthlyReportCsv(
                              report,
                              logs: logs,
                              userDisplay: widget.title ?? p?.displayName,
                              userEmail: widget.email?.isNotEmpty == true
                                  ? widget.email
                                  : p?.email, // ⬅️ preferuj email z Firestore
                            );
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
                            final p = await _profiles.fetchProfile(widget.uid);
                            final path = await CsvUtils.saveMonthlyReportCsv(
                              report,
                              logs: logs,
                              userDisplay: widget.title ?? p?.displayName,
                              userEmail: widget.email?.isNotEmpty == true
                                  ? widget.email
                                  : p?.email,
                            );
                            await Share.shareXFiles(
                              [XFile(path)],
                              text:
                                  'WorkTick ${report.year}-${report.month.toString().padLeft(2, '0')}',
                            );
                          },
                        )
                      ],
                    ),
                  ),
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
                              final dateLabel = DateFormat.yMMMMEEEEd(context.locale.toString())
                                  .format(d.day);
                              final totalDay = formatDurationHM(d.minutesTotal);

                              return ListTile(
                                leading: const Icon(Icons.calendar_today),
                                title: Text('$dateLabel  ·  $totalDay'),
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
