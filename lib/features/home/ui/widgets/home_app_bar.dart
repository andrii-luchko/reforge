import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/router/routes.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

import 'package:reforge/generated/flutter_gen/assets.gen.dart';

import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final topPadding = MediaQuery.paddingOf(context).top;
    const headerHeight = 72.0;

    return SliverPersistentHeader(
      delegate: _HomeHeaderDelegate(
        topPadding: topPadding,
        height: headerHeight,
        appTheme: appTheme,
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeHeaderDelegate({
    required this.topPadding,
    required this.height,
    required this.appTheme,
  });

  final double topPadding;
  final double height;
  final AppTheme appTheme;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.transparent,
      elevation: overlapsContent ? 2 : 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: appTheme.beige100,
                  shape: BoxShape.circle,
                  border: GradientBoxBorder(gradient: appTheme.avatarGradient, width: 2),
                ),
                child: Center(child: SvgPicture.asset(Assets.images.icons.user)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: subheadH5Medium.copyWith(color: appTheme.beige500),
                    ),
                    Text(
                      'Hey, Jacob!',
                      style: subheadH1Medium.copyWith(color: appTheme.beige100),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                iconAsset: Assets.images.icons.calendar,
                onPressed: () => const CalendarPageRoute().push<void>(context),
              ),
              const SizedBox(width: 8),
              AppIconButton(
                iconAsset: Assets.images.icons.bell,
                onPressed: () => const NotificationsPageRoute().push<void>(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height + topPadding;

  @override
  double get minExtent => height + topPadding;

  @override
  bool shouldRebuild(covariant _HomeHeaderDelegate oldDelegate) {
    return oldDelegate.appTheme != appTheme;
  }
}
