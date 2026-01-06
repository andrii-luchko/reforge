import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({required this.leadingIcon, required this.subtitle, required this.title, super.key});

  final Widget leadingIcon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: appTheme.radioButtonGradient,

        border: Border.all(
          color: appTheme.strokeCard,
        ),
      ),
      child: Row(
        children: [
          leadingIcon,
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: .start,
            spacing: 7,
            children: [
              Text(
                title,
                style: subheadH3Medium.copyWith(color: appTheme.beige100),
              ),

              Text(
                subtitle,
                style: subheadH6Regular.copyWith(color: appTheme.beige600),
              ),
            ],
          ),

          const Spacer(),

          Icon(
            Icons.chevron_right_rounded,
            size: 36,
            color: appTheme.beige100,
          ),
        ],
      ),
    );
  }
}
