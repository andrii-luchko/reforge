import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class BadgeListTile extends StatelessWidget {
  const BadgeListTile({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,

    super.key,
  });

  final Widget leadingIcon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: appTheme.beige900,
        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          leadingIcon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 7,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: subheadH3Medium.copyWith(color: appTheme.beige100),
                ),

                Text(
                  subtitle,
                  style: subheadH6Regular.copyWith(color: appTheme.beige600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
