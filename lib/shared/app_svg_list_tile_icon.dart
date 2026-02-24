import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/app_cached_net_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppSvgListTileIcon extends StatelessWidget {
  const AppSvgListTileIcon.network({
    required String url,
    this.color,
    this.height = 24,
    this.width = 24,
    this.padding = const EdgeInsets.all(16),
    super.key,
  }) : _path = url,
       _isAsset = false;

  const AppSvgListTileIcon.asset({
    required String asset,
    this.color,
    super.key,
    this.height = 24,
    this.width = 24,
    this.padding = const EdgeInsets.all(16),
  }) : _path = asset,
       _isAsset = true;

  final bool _isAsset;
  final String _path;
  final Color? color;
  final EdgeInsets padding;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Skeleton.leaf(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: .circle,
          color: appTheme.beige900,
          border: GradientBoxBorder(
            gradient: LinearGradient(
              begin: .topLeft,
              end: .bottomRight,
              colors: [
                appTheme.beige100.withValues(alpha: 0.4),
                appTheme.beige100.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        child: Center(
          child: Padding(
            padding: padding,
            child: _buildImage(context),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (_isAsset) {
      return SvgPicture.asset(
        height: height,
        width: width,
        _path,

        colorFilter: ColorFilter.mode(color ?? context.appTheme.beige700, .srcIn),
      );
    } else {
      return AppCachedNetSVGImage(
        height: height,
        width: width,
        imageUrl: _path,
        fit: .fill,
        errorWidget: const Icon(
          Icons.image_not_supported_rounded,
        ),
      );
    }
  }
}
