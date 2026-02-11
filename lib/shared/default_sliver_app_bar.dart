import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DefaultSliverAppBar extends StatelessWidget {
  const DefaultSliverAppBar({required this.onPressed, required this.title, super.key});

  final VoidCallback onPressed;
  final String title;

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return SliverPadding(
      padding: horizontalPadding,
      sliver: SliverAppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,

        centerTitle: false,
        leadingWidth: 56,
        leading: AppIconButton.icon(
          iconData: Icons.chevron_left_rounded,
          iconSize: 32,

          onPressed: onPressed,
        ),

        actions: [
          Skeleton.keep(
            child: Text(
              title,
              style: subheadH1Medium.copyWith(color: appTheme.beige100),
            ),
          ),
        ],
      ),
    );
  }
}
