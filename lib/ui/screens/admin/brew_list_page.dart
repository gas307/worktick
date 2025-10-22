import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../widgets/active_dot.dart';
import '../my_logs/my_logs_body.dart';
import '../reports/report_page.dart';
import '../reports/report_all_page.dart';

class BrewListPage extends StatefulWidget {
  const BrewListPage({super.key});

  @override
  State<BrewListPage> createState() => _BrewListPageState();
}

class _BrewListPageState extends State<BrewListPage> {
  final _repo = ProfileRepository();

  String? _selectedUid;
  String? _selectedTitle;
  String? _selectedEmail;

  bool _showUserReport = false; // w trybie szczegółu
  bool _showOrgReport = false;  // w trybie listy

  void _resetSelection() {
    setState(() {
      _selectedUid = null;
      _selectedTitle = null;
      _selectedEmail = null;
      _showUserReport = false;
      _showOrgReport = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // === TRYB SZCZEGÓŁU UŻYTKOWNIKA ===
    if (_selectedUid != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pasek z powrotem + tytuł + mail + przełącznik Wpisy/Raport
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Wstecz',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _resetSelection,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedTitle != null && _selectedTitle!.isNotEmpty)
                        Text(
                          _selectedTitle!,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (_selectedEmail != null && _selectedEmail!.isNotEmpty)
                        Text(
                          _selectedEmail!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Przełącznik: Wpisy / Raport
                SegmentedButton<bool>(
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  segments: [
                    ButtonSegment(value: false, icon: const Icon(Icons.list), label: Text('app.myLogs'.tr())),
                    ButtonSegment(value: true,  icon: const Icon(Icons.summarize), label: const Text('Raport')),
                  ],
                  selected: {_showUserReport},
                  onSelectionChanged: (s) => setState(() => _showUserReport = s.first),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _showUserReport
                ? ReportPage(
                    uid: _selectedUid!,
                    title: _selectedTitle,
                    email: _selectedEmail, // ⬅️ PRZEKAZUJEMY E-MAIL
                  )
                : MyLogsBody(forUid: _selectedUid),
          ),
        ],
      );
    }

    // === TRYB LISTY UŻYTKOWNIKÓW / RAPORT WSZYSTKICH ===
    return StreamBuilder(
      stream: _repo.watchAllProfiles(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final profiles = snap.data!.docs.map((d) => Profile.fromDoc(d)).toList();

        // Pasek narzędzi nad listą
        final header = Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text('app.adminList'.tr(), style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              SegmentedButton<bool>(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: const [
                  ButtonSegment(value: false, icon: Icon(Icons.people), label: Text('Lista')),
                  ButtonSegment(value: true,  icon: Icon(Icons.summarize), label: Text('Raport')),
                ],
                selected: {_showOrgReport},
                onSelectionChanged: (s) => setState(() => _showOrgReport = s.first),
              ),
            ],
          ),
        );

        if (_showOrgReport) {
          return Column(
            children: [
              header,
              const Divider(height: 1),
              const Expanded(child: ReportAllPage()), // raport zbiorczy POD navbarem
            ],
          );
        }

        if (profiles.isEmpty) {
          return Column(
            children: [
              header,
              const Divider(height: 1),
              Expanded(
                child: Center(
                  child: Text('Brak użytkowników', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            header,
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: profiles.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = profiles[i];
                  final name = (p.displayName ?? '').trim();
                  final email = (p.email ?? '').trim();

                  final title = name.isNotEmpty ? name : (email.isNotEmpty ? email : p.uid);
                  final emailText = email.isNotEmpty ? email : '—';

                  return ListTile(
                    leading: ActiveDot(active: p.active),
                    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '$emailText · ${p.active ? 'app.active'.tr() : 'app.inactive'.tr()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _selectedUid = p.uid;
                        _selectedTitle = title;
                        _selectedEmail = email;
                        _showUserReport = false;
                      });
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
