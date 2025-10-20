import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart';
import 'providers/settings_provider.dart';

class WorkTickApp extends StatelessWidget {
  const WorkTickApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkTick',
      theme: WorkTickTheme.light,
      darkTheme: WorkTickTheme.dark,
      themeMode: settings.themeMode,

      // easy_localization
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(settings.textScale)),
          child: child!,
        );
      },
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.wrapper,
    );
  }
}
