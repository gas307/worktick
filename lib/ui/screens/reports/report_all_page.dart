import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/worklog_repository.dart';
import '../../../data/models/work_log.dart';
import '../../../data/models/report_models.dart';
import '../../../data/services/report_service.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/utils/csv_utils.dart';

class ReportAllPage extends StatefulWidget {
  const ReportAllPage({super.key});

  @override
  State<ReportAllPage> createState() => _ReportAllPageState();
}

class _ReportAllPageState extends State<ReportAllPage> {
  final _profilesRepo = ProfileRepository();
  final _workRepo = WorklogRepository();
  final _orgService = OrgReportService();

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
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return Center(child: Text('Brak uprawnień (admin only).'));
    }

    final y = _month.year;
    final m = _month.month;
    final header = toBeginningOfSentenceCase(
          DateFormat.yMMMM(context.locale.toString()).format(_month),
        ) ??
        '';

    return Column(
      children: [
        // Nawigacja po miesiącach
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: FutureBuilder<OrgMonthlyReport>(
            future: _loadReport(y, m),
            builder: (context, snap) {
              if (!snap.hasData) {
                if (snap.hasError) {
                  return Center(child: Text('Błąd: ${snap.error}'));
                }
                return const Center(child: CircularProgressIndicator());
              }
              final report = snap.data!;

              return Column(
                children: [
                  // Eksport bez chipów
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        const Spacer(),
                        FilledButton.icon(
                          icon: const Icon(Icons.file_download),
                          label: const Text('CSV'),
                          onPressed: () async {
                            final path = await CsvUtils.saveOrgMonthlyReportCsv(report);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Zapisano CSV: $path')),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.ios_share),
                          label:  Text('app.share'.tr()),
                          onPressed: () async {
                            final path = await CsvUtils.saveOrgMonthlyReportCsv(report);
                            await Share.shareXFiles(
                              [XFile(path)],
                              text: 'WorkTick Org $y-${m.toString().padLeft(2, '0')}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // lista użytkowników (bez sum per typ)
                  Expanded(
                    child: report.users.isEmpty
                        ? Center(child: Text('app.noLogsYet'.tr()))
                        : ListView.separated(
                            itemCount: report.users.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final u = report.users[i];
                              final title = (u.displayName?.isNotEmpty ?? false)
                                  ? u.displayName!
                                  : (u.email?.isNotEmpty ?? false)
                                      ? u.email!
                                      : u.uid;
                              return ListTile(
                                leading: CircleAvatar(child: Text('${i + 1}')),
                                title: Text('$title  ·  ${formatDurationHM(u.totalMinutes)}'),
                                // usunięto subtitle z typami
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

  Future<OrgMonthlyReport> _loadReport(int year, int month) async {
    final profiles = await _profilesRepo.fetchAllProfiles();

    final users = <String, ({String? displayName, String? email})>{};
    for (final p in profiles) {
      users[p.uid] = (displayName: p.displayName, email: p.email);
    }

    final logsByUid = <String, List<WorkLog>>{};
    await Future.wait(profiles.map((p) async {
      final logs = await _workRepo.fetchLogsForMonth(p.uid, year, month);
      logsByUid[p.uid] = logs;
    }));

    return _orgService.buildOrgMonthlyReport(
      year: year,
      month: month,
      users: users,
      logsByUid: logsByUid,
    );
  }
}
