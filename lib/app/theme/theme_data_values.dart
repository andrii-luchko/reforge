import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme_values.dart';
import 'package:reforge/generated/flutter_gen/fonts.gen.dart';

class ThemeDataValues {
  static ThemeData get lightThemeData => ThemeData(
    fontFamily: FontFamily.orbitron,
    fontFamilyFallback: const [FontFamily.clashGrotesk],
    scaffoldBackgroundColor: AppThemeValues.light.beige1000,
    colorScheme: ColorScheme.light(primary: AppThemeValues.light.orange500),

    extensions: [AppThemeValues.light],
  );

  static ThemeData get darkThemeData => ThemeData(
    fontFamily: FontFamily.orbitron,
    fontFamilyFallback: const [FontFamily.clashGrotesk],
    scaffoldBackgroundColor: AppThemeValues.dark.beige1000,
    colorScheme: ColorScheme.dark(primary: AppThemeValues.light.orange500),

    extensions: [AppThemeValues.dark],
  );
}
