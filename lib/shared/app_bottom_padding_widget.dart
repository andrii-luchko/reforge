import 'package:flutter/material.dart';
import 'package:reforge/app/utils/extensions/media_query_extension.dart';
import 'package:reforge/shared/uikit/app_bottom_bar.dart';

class AppBottomPaddingWidget extends StatelessWidget {
  const AppBottomPaddingWidget({
    this.child,
    this.extraSpace = 16,
    super.key,
  }) : _isSliver = false;

  const AppBottomPaddingWidget.sliver({
    this.child,
    this.extraSpace = 16,
    super.key,
  }) : _isSliver = true;

  const AppBottomPaddingWidget.sliverWithAppBottomBarHeight({
    this.child,
    super.key,
  }) : _isSliver = true,
       extraSpace = AppBottomBar.totalHeight;

  final bool _isSliver;
  final double extraSpace;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = EdgeInsets.only(bottom: context.mediaQueryBottomPadding + extraSpace);

    return _isSliver
        ? SliverPadding(
            padding: bottomPadding,
            sliver: child,
          )
        : Padding(
            padding: bottomPadding,
            child: child,
          );
  }
}
