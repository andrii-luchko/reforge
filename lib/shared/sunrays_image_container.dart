import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/animations/shaders/sunrays_shader.dart';
import 'package:reforge/shared/app_cached_net_image.dart';
import 'package:reforge/shared/uikit/blur_container.dart';
import 'package:reforge/shared/uikit/glass_container.dart';

class SunRaysImageContainer extends StatelessWidget {
  const SunRaysImageContainer.network({
    required String url,
    this.width = 200,
    this.height = 200,
    this.reyLength = 0.11,
    super.key,
  }) : _path = url,
       _isAsset = false;

  const SunRaysImageContainer.asset({
    required String asset,
    this.width = 200,
    this.height = 200,
    this.reyLength = 0.11,
    super.key,
  }) : _path = asset,
       _isAsset = true;

  final double width;
  final double height;
  final double reyLength;

  final String _path;
  final bool _isAsset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: height,
          width: width,
          child: SunRaysShaderWidget.fromBehind(
            color: context.appTheme.orange500,
          ),
        ),
        BlurContainer(
          sigmaX: 20,
          sigmaY: 20,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: height,
            width: width,
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              child: _buildImage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (_isAsset) {
      return Image.asset(
        _path,
        fit: BoxFit.contain,
      );
    } else {
      return AppCachedNetImage(
        imageUrl: _path,
      );
    }
  }
}
