import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/worklog_repository.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/work_log.dart';
import '../../widgets/work_type_selector.dart';
import '../../widgets/work_log_tile.dart';
import '../../widgets/edit_log_dialog.dart';
import '../../widgets/worktick_calendar.dart';
import '../../../core/utils/time_utils.dart'; 
import '../reports/report_page.dart';
class MyLogsBody extends StatefulWidget {
  final String? forUid; // jeśli admin wchodzi w profil pracownika
  const MyLogsBody({super.key, this.forUid});

  @override
  State<MyLogsBody> createState() => _MyLogsBodyState();
}

class _MyLogsBodyState extends State<MyLogsBody> {
  final _profileRepo = ProfileRepository();
  final _workRepo = WorklogRepository();
  final _noteCtrl = TextEditingController();
  String workType = 'office';
  bool calendarMode = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final uid = widget.forUid ?? auth.user!.uid;
    final isAdmin = auth.isAdmin;

    return StreamBuilder(
      stream: _profileRepo.watchProfile(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = Profile.fromDoc(snapshot.data!);

        return Column(
          children: [
            // === Sekcja start/stop pracy ===
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      profile.active ? 'app.active'.tr() : 'app.inactive'.tr(),
                    ),
                    avatar: Icon(
                      profile.active ? Icons.circle : Icons.circle_outlined,
                      size: 16,
                      color: profile.active ? Colors.green : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _noteCtrl,
                      decoration: InputDecoration(
                        labelText: 'app.note'.tr(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  WorkTypeSelector(
                    value: workType,
                    onChanged: (v) => setState(() => workType = v),
                  ),
                  const SizedBox(width: 12),
                  if (!profile.active)
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: Text('app.start'.tr()),
                      onPressed: () async {
                        await _profileRepo.startWork(
                          uid: uid,
                          workType: workType,
                          note: _noteCtrl.text.trim().isEmpty
                              ? null
                              : _noteCtrl.text.trim(),
                        );
                        _noteCtrl.clear();
                      },
                    )
                  else
                    FilledButton.icon(
                      icon: const Icon(Icons.stop),
                      label: Text('app.stop'.tr()),
                      onPressed: () async {
                        await _profileRepo.stopWork(uid);
                      },
                    ),
                ],
              ),
            ),

            // === Przełącznik widoku (lista/kalendarz) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text('app.list'.tr()),
                        icon: const Icon(Icons.list),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('app.calendar'.tr()),
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ],
                    selected: {calendarMode},
                    onSelectionChanged: (s) =>
                        setState(() => calendarMode = s.first),
                  ),
                  
                  const Spacer(),
                  if (profile.active && profile.activeStart != null)
                    Text(
                      '${'app.today'.tr()}: ${DateFormat.Hm().format(profile.activeStart!)}',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // === Główna sekcja: logi lub kalendarz ===
            Expanded(
              child: StreamBuilder<List<WorkLog>>(
                stream: _workRepo.watchLogs(uid),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final logs = snap.data!;
                  if (calendarMode) {
                    // Kalendarz z miesięcznym podsumowaniem
                    return WorkTickCalendar(logs: logs);
                  }
                  if (logs.isEmpty) {
                    return Center(
                      child: Text(
                        'app.noLogsYet'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  // Lista logów
                  return ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final log = logs[i];
                      return WorkLogTile(
                        log: log,
                        canEdit: isAdmin,
                        onEdit: () async {
                          final updated = await showDialog<WorkLog>(
                            context: context,
                            builder: (_) => EditLogDialog(initial: log),
                          );
                          if (updated != null) {
                            await _workRepo.updateLog(uid, updated);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
