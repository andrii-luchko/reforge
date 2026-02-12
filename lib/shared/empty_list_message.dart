import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/centered_title_section.dart';

class SliverEmptyListMessage extends StatelessWidget {
  const SliverEmptyListMessage({required this.title, required this.subtitle, required this.icon, super.key});

  final IconData? icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyListMessage(
        title: title,
        subtitle: subtitle,
        icon: icon,
      ),
    );
  }
}

class EmptyListMessage extends StatelessWidget {
  const EmptyListMessage({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconSize = 64,
    super.key,
  });

  final IconData? icon;
  final String title;
  final String subtitle;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: appTheme.beige700,
          ),
          const SizedBox(height: 16),
          CenteredTitleSection(
            title: title,
            subtitle: subtitle,
          ),
        ],
      ),
    );
  }
}
