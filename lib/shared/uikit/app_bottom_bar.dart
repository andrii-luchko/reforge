import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void onTabSelect(int index) {
    navigationShell.goBranch(
      index,

      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final currentIndex = navigationShell.currentIndex;

    return Container(
      width: double.infinity,
      padding: const .all(6),
      margin: const .only(left: 10, right: 10, bottom: 24),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        border: GradientBoxBorder(gradient: appTheme.menuBar),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            offset: const Offset(0, 20),
            blurRadius: 30,
            spreadRadius: 20,
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          AppBottomBarItem(
            activeIcon: Assets.images.icons.homeActive,
            inactiveIcon: Assets.images.icons.homeInactive,
            isActive: currentIndex == 0,
            onTap: () => onTabSelect(0),
          ),
          AppBottomBarItem(
            activeIcon: Assets.images.icons.chartActive,
            inactiveIcon: Assets.images.icons.chartInactive,
            isActive: currentIndex == 1,
            onTap: () => onTabSelect(1),
          ),
          AppBottomBarItem(
            activeIcon: Assets.images.icons.platesActive,
            inactiveIcon: Assets.images.icons.platesInactive,
            isActive: currentIndex == 2,
            onTap: () => onTabSelect(2),
          ),
          AppBottomBarItem(
            activeIcon: Assets.images.icons.medalActive,
            inactiveIcon: Assets.images.icons.medalInactive,
            isActive: currentIndex == 3,
            onTap: () => onTabSelect(3),
          ),
          AppBottomBarItem(
            activeIcon: Assets.images.icons.settingActive,
            inactiveIcon: Assets.images.icons.settingInactive,
            isActive: currentIndex == 4,
            onTap: () => onTabSelect(4),
          ),
        ],
      ),
    );
  }
}

class AppBottomBarItem extends StatelessWidget {
  const AppBottomBarItem({
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    this.onTap,
    super.key,

    this.size = const Size(56, 56),
    this.iconSize = const Size(24, 24),
  });

  final Size size;
  final Size iconSize;

  final bool isActive;
  final VoidCallback? onTap;
  final String activeIcon;
  final String inactiveIcon;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final iconAsset = isActive ? activeIcon : inactiveIcon;
    final border = isActive ? appTheme.menuButton : null;
    final backgroundColor = isActive ? appTheme.orange500 : Colors.transparent;
    final iconColor = isActive ? appTheme.beige100 : appTheme.beige700;
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: Durations.short2,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: border,
          shape: BoxShape.circle,
        ),
        padding: const .all(1),
        child: AnimatedContainer(
          duration: Durations.short2,
          curve: Curves.easeInOut,
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: .center,

            children: [
              SvgPicture.asset(
                iconAsset,
                width: iconSize.width,
                height: iconSize.height,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),

              if (isActive)
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: appTheme.beige100, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
