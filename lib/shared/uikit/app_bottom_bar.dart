import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const double totalHeight = 68 + 24;

  @override
  State<AppBottomBar> createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  int? _draggedIndex;

  void _onTabSelect(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    final currentIndex = widget.navigationShell.currentIndex;

    final visualIndex = _draggedIndex ?? currentIndex;

    const itemSize = 56.0;
    const itemCount = 5;

    final items = [
      (active: Assets.images.icons.homeActive, inactive: Assets.images.icons.homeInactive),
      (active: Assets.images.icons.chartActive, inactive: Assets.images.icons.chartInactive),
      (active: Assets.images.icons.platesActive, inactive: Assets.images.icons.platesInactive),
      (active: Assets.images.icons.medalActive, inactive: Assets.images.icons.medalInactive),
      (active: Assets.images.icons.settingActive, inactive: Assets.images.icons.settingInactive),
    ];

    return Container(
      width: double.infinity,
      height: 68,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 24),
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
      child: LayoutBuilder(
        builder: (_, constraints) {
          final totalWidth = constraints.maxWidth;
          final tabWidth = totalWidth / itemCount;
          final centerOffset = (tabWidth - itemSize) / 2;

          int calculateIndex(double dx) {
            return (dx / tabWidth).floor().clamp(0, itemCount - 1);
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,

            onHorizontalDragStart: (details) {
              final index = calculateIndex(details.localPosition.dx);
              setState(() {
                _draggedIndex = index;
              });
              unawaited(HapticFeedback.selectionClick());
            },

            onHorizontalDragUpdate: (details) async {
              final newIndex = calculateIndex(details.localPosition.dx);

              if (newIndex != _draggedIndex) {
                setState(() {
                  _draggedIndex = newIndex;
                });
                unawaited(HapticFeedback.selectionClick());
              }
            },

            onHorizontalDragEnd: (details) {
              if (_draggedIndex != null) {
                _onTabSelect(_draggedIndex!);
                setState(() {
                  _draggedIndex = null;
                });
              }
            },

            onHorizontalDragCancel: () {
              setState(() {
                _draggedIndex = null;
              });
            },

            onTapUp: (details) {
              final index = calculateIndex(details.localPosition.dx);
              _onTabSelect(index);
            },

            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutCubic,

                  top: 0,
                  bottom: 0,
                  width: itemSize,

                  left: (visualIndex * tabWidth) + centerOffset,

                  child: Container(
                    decoration: BoxDecoration(
                      color: appTheme.orange500,
                      shape: BoxShape.circle,
                      border: GradientBoxBorder(
                        gradient: appTheme.menuButton,
                      ),
                    ),
                  ),
                ),

                Row(
                  children: List.generate(items.length, (index) {
                    return Expanded(
                      child: AppBottomBarItem(
                        isActive: visualIndex == index,
                        activeIcon: items[index].active,
                        inactiveIcon: items[index].inactive,
                        size: const Size(itemSize, itemSize),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AppBottomBarItem extends StatelessWidget {
  const AppBottomBarItem({
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.size,
    super.key,
    this.iconSize = const Size(24, 24),
  });

  final Size size;
  final Size iconSize;
  final bool isActive;
  final String activeIcon;
  final String inactiveIcon;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final iconColor = isActive ? appTheme.beige100 : appTheme.beige700;
    final iconAsset = isActive ? activeIcon : inactiveIcon;

    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isActive ? 1.1 : 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: SvgPicture.asset(
              iconAsset,
              width: iconSize.width,
              height: iconSize.height,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(top: 4),
            width: isActive ? 4 : 0,
            height: isActive ? 4 : 0,
            decoration: BoxDecoration(
              color: appTheme.beige100,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
