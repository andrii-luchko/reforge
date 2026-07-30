import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/horizontal_xp_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class XpTile extends StatelessWidget {
  const XpTile({required this.currentXp, required this.totalXp, super.key});

  final int currentXp;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final progress = totalXp <= 0 ? 0.0 : (currentXp / totalXp).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    final appTheme = context.appTheme;

    final currentXpFormatted = XpFormatter.compact(currentXp);
    final totalXpFormatted = XpFormatter.compact(totalXp);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                context.t.home.xp_earned,
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),
              Text('$percentage%', style: subheadH3Medium.copyWith(color: appTheme.beige600)),
            ],
          ),
          const SizedBox(height: 20),

          Skeleton.leaf(child: HorizontalXPBar(progress: progress)),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(currentXpFormatted, style: subheadH5Medium.copyWith(color: appTheme.beige100)),
              Text(totalXpFormatted, style: subheadH5Medium.copyWith(color: appTheme.beige100)),
            ],
          ),
        ],
      ),
    );
  }
}
