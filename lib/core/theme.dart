import 'package:flutter/material.dart';

class WorkTickTheme {
  static const _seed = Colors.indigo;

  static ThemeData get light => ThemeData(
    colorSchemeSeed: _seed,
    brightness: Brightness.light,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: false),
  );

  static ThemeData get dark => ThemeData(
    colorSchemeSeed: _seed,
    brightness: Brightness.dark,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: false),
  );
}
