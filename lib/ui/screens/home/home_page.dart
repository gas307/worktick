import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/worktick_app_bar.dart';
import '../../../providers/auth_provider.dart';
import '../admin/brew_list_page.dart';
import '../my_logs/my_logs_body.dart';
import '../settings/settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    void goSettings() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );

    return Scaffold(
      appBar: WorkTickAppBar(
        onSettings: goSettings,
        onLogout: () => context.read<AuthProvider>().signOut(),
      ),
      // ⬇️ bez const – inaczej nie zareaguje na zmianę locale
      body: auth.isAdmin ? BrewListPage() : MyLogsBody(),
    );
  }
}
