import 'package:flutter/material.dart';

import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/shared/app_cached_net_image.dart';

import 'package:reforge/shared/uikit/glass_container.dart';

class BadgeImage extends StatelessWidget {
  const BadgeImage.network({
    required String url,
    super.key,
  }) : _path = url,
       _isAsset = false;

  const BadgeImage.asset({
    required String asset,
    super.key,
  }) : _path = asset,
       _isAsset = true;

  final String _path;
  final bool _isAsset;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(11);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: context.appTheme.beige900,
        ),
        child: GlassContainer(
          borderRadius: borderRadius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment(-0.45, -0.97),
                end: Alignment(0.88, 0.91),
                colors: [
                  Color(0x009D3C10),
                  Color(0x339D3C10),
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: _buildImage(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_isAsset) {
      return Image.asset(
        _path,
      );
    } else {
      return AppCachedNetSVGImage(
        imageUrl: _path,
        errorWidget: const Icon(
          Icons.image_not_supported_rounded,
        ),
      );
    }
  }
}
