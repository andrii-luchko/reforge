import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';

Gradient getGradientByRank(int rank, BuildContext context) {
  switch (rank) {
    case 1:
      return context.appTheme.goldGradient;
    case 2:
      return context.appTheme.silverGradient;
    case 3:
      return context.appTheme.bronzeGradient;
    case 4:
      return context.appTheme.ironGradient;

    case 5:
      return context.appTheme.steelGradient;
    default:
      return context.appTheme.woodGradient;
  }
}
