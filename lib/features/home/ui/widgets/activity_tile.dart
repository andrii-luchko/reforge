import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, this.showBorder = true});
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final primaryStyle = subheadH2Medium.copyWith(color: appTheme.beige100);
    final secondaryStyle = subheadH2Medium.copyWith(color: appTheme.beige600);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
        border: showBorder
            ? Border.all(
                color: appTheme.strokeCard,
              )
            : null,
      ),
      padding: const .all(16),
      child: Row(
        children: [
          AppIconButton(iconAsset: Assets.images.icons.calendar2),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: .start,
            spacing: 7,
            children: [
              Text(
                'Active Days',
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),

              Text(
                'Tuesday',
                style: subheadH6Regular.copyWith(color: appTheme.beige600),
              ),
            ],
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '1', style: primaryStyle),
                TextSpan(text: ' / 3', style: secondaryStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
