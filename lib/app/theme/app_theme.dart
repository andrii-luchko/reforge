import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'app_theme.g.theme.dart';

@themeExtensions
class AppTheme extends ThemeExtension<AppTheme> with _$AppTheme {
  const AppTheme({
    // Beige palette
    required this.beige50,
    required this.beige100,
    required this.beige200,
    required this.beige300,
    required this.beige400,
    required this.beige500,
    required this.beige600,
    required this.beige700,
    required this.beige800,
    required this.beige900,
    required this.beige1000,

    // Orange palette
    required this.orange100,
    required this.orange200,
    required this.orange300,
    required this.orange400,
    required this.orange500,
    required this.orange600,
    required this.orange60,
    required this.orangeButton,

    required this.styleCard,

    required this.strokeCard,
    required this.strokeCalendar,

    required this.red400,
    required this.avatarGradient,
    required this.menuBar,
    required this.menuButton,
    required this.radioButtonGradient,
    required this.gradientXpBar,
  });

  // Beige palette
  final Color beige50;
  final Color beige100;
  final Color beige200;
  final Color beige300;
  final Color beige400;
  final Color beige500;
  final Color beige600;
  final Color beige700;
  final Color beige800;
  final Color beige900;
  final Color beige1000;

  // Orange palette
  final Color orange100;
  final Color orange200;
  final Color orange300;
  final Color orange400;
  final Color orange500;
  final Color orange600;
  final Color orange60;
  final Color orangeButton;
  final LinearGradient styleCard;
  final Color strokeCard;

  final Color strokeCalendar;

  final Color red400;
  final RadialGradient avatarGradient;
  final RadialGradient radioButtonGradient;
  final LinearGradient menuBar;
  final LinearGradient menuButton;
  final LinearGradient gradientXpBar;
}
