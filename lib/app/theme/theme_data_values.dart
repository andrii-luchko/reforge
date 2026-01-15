import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme_values.dart';
import 'package:reforge/generated/flutter_gen/fonts.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ThemeDataValues {
  static final skeletonizerConfig = SkeletonizerConfigData(
    effect: ShimmerEffect(
      baseColor: AppThemeValues.light.beige800,
      highlightColor: AppThemeValues.light.beige700,
      duration: const Duration(seconds: 3),
    ),
  );

  static ThemeData get lightThemeData => ThemeData(
    fontFamily: FontFamily.orbitron,
    fontFamilyFallback: const [FontFamily.clashGrotesk],
    scaffoldBackgroundColor: AppThemeValues.light.beige1000,
    colorScheme: ColorScheme.light(primary: AppThemeValues.light.orange500),

    extensions: [
      AppThemeValues.light,
      skeletonizerConfig,
    ],
  );

  static ThemeData get darkThemeData => ThemeData(
    fontFamily: FontFamily.orbitron,
    fontFamilyFallback: const [FontFamily.clashGrotesk],
    scaffoldBackgroundColor: AppThemeValues.dark.beige1000,
    colorScheme: ColorScheme.dark(primary: AppThemeValues.light.orange500),

    extensions: [AppThemeValues.dark, skeletonizerConfig],
  );
}
