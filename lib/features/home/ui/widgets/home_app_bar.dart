import 'package:flutter/material.dart';
import 'package:reforge/app/router/routes.dart';

import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/leaderboard/ui/widgets/leaderboard_avatar.dart';

import 'package:reforge/generated/flutter_gen/assets.gen.dart';

import 'package:reforge/shared/uikit/buttons/icon_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({required this.username, required this.imageUrl, super.key});

  final String? username;
  final String? imageUrl;

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
        username: username,
        imageUrl: imageUrl,
      ),
    );
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeHeaderDelegate({
    required this.username,
    required this.imageUrl,
    required this.topPadding,
    required this.height,
    required this.appTheme,
  });

  final double topPadding;
  final double height;
  final AppTheme appTheme;
  final String? username;
  final String? imageUrl;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final name = username ?? 'Forger';
    return Material(
      color: Colors.transparent,
      elevation: overlapsContent ? 2 : 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              Skeleton.leaf(
                child: LeaderBoardAvatar(
                  size: const Size(56, 56),
                  borderGradientColors: appTheme.avatarGradient,
                  imageUrl: imageUrl,
                  secondBorderWidth: 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Skeleton.unite(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: subheadH5Medium.copyWith(color: appTheme.beige500),
                      ),
                      FittedBox(
                        child: Text(
                          'Hey, $name!',
                          style: subheadH1Medium.copyWith(color: appTheme.beige100),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
    return oldDelegate.imageUrl != imageUrl || oldDelegate.username != username;
  }
}
