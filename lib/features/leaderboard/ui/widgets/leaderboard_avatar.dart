import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/app_cached_net_image.dart';

enum _ImageType { network, asset, empty }

class LeaderBoardAvatar extends StatelessWidget {
  const LeaderBoardAvatar.network({
    required this.borderGradientColors,
    required String? imageUrl,
    required this.size,
    this.gradientWidth = 3,
    this.secondBorderWidth = 3,
    super.key,
  }) : _imageUrl = imageUrl,
       _imageType = imageUrl == null ? _ImageType.empty : _ImageType.network;

  const LeaderBoardAvatar.asset({
    required this.borderGradientColors,
    required String assetPath,
    required this.size,
    this.gradientWidth = 3,
    this.secondBorderWidth = 3,
    super.key,
  }) : _imageUrl = assetPath,
       _imageType = _ImageType.asset;

  final Size size;
  final Gradient borderGradientColors;
  final double gradientWidth;
  final double secondBorderWidth;

  final String? _imageUrl;
  final _ImageType _imageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: GradientBoxBorder(
          width: gradientWidth,
          gradient: borderGradientColors,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appTheme.beige200,
          border: Border.all(
            color: const Color(0xFFECE7DC),
            width: secondBorderWidth,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    switch (_imageType) {
      case _ImageType.network:
        return AppCachedNetImage(imageUrl: _imageUrl!);
      case _ImageType.asset:
        return Image.asset(
          _imageUrl!,
          fit: BoxFit.cover,
        );
      case _ImageType.empty:
        return const AppUserImageEmptyWidget();
    }
  }
}
