import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('app.settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('app.language'.tr()),
            subtitle: Text(
              context.locale.languageCode == 'pl'
                  ? 'app.polish'.tr()
                  : 'app.english'.tr(),
            ),
            trailing: DropdownButton<Locale>(
              value: context.locale,
              onChanged: (l) {
                if (l != null) context.setLocale(l);
              },
              items: const [
                DropdownMenuItem(value: Locale('pl'), child: Text('PL')),
                DropdownMenuItem(value: Locale('en'), child: Text('EN')),
              ],
            ),
          ),
          const Divider(),
          ListTile(title: Text('app.theme'.tr())),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setTheme(v!),
            title: Text('app.system'.tr()),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setTheme(v!),
            title: Text('app.light'.tr()),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (v) => settings.setTheme(v!),
            title: Text('app.dark'.tr()),
          ),
          const Divider(),
          ListTile(
            title: Text('app.textScale'.tr()),
            subtitle: Text(settings.textScale.toStringAsFixed(2)),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                min: 0.8,
                max: 1.4,
                divisions: 6,
                value: settings.textScale,
                onChanged: (v) => settings.setTextScale(v),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
