import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.leadingIcon,
    required this.subtitle,
    required this.title,
    this.onTap,
    super.key,
  });

  final Widget leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        splashFactory: InkSparkle.splashFactory,
        splashColor: appTheme.beige100.withValues(alpha: 0.1),
        highlightColor: appTheme.beige100.withValues(alpha: 0.01),

        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
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
        ),
      ),
    );
  }
}
