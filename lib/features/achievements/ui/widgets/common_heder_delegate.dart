import 'package:flutter/material.dart';

class CommonHeaderDelegate extends SliverPersistentHeaderDelegate {
  CommonHeaderDelegate({
    required this.child,
    this.height = 50.0,
  });
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant CommonHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
