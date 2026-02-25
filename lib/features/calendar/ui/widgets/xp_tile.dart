import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/horizontal_xp_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class XpTile extends StatelessWidget {
  const XpTile({required this.progress, required this.xp, super.key});
  final int xp;
  final double progress;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appTheme.strokeCard),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            context.t.home.xp_earned,
            style: subheadH3Medium.copyWith(color: appTheme.beige100),
          ),
          const SizedBox(height: 12),
          Skeleton.leaf(
            child: Row(
              children: [
                Expanded(
                  child: HorizontalXPBar(
                    progress: progress,
                    barSize: const Size.fromHeight(20),
                  ),
                ),
                const SizedBox(width: 10),
                Text(XpFormatter.compact(xp), style: subheadH5Medium.copyWith(color: appTheme.beige100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
