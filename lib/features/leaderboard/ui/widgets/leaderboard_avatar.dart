import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/shared/app_cached_net_image.dart';

class LeaderBoardAvatar extends StatelessWidget {
  const LeaderBoardAvatar({
    required this.borderGradientColors,
    required this.imageUrl,
    required this.size,
    this.gradientWidth = 3,
    this.secondBorderWidth = 3,
    super.key,
  });

  final Size size;
  final Gradient borderGradientColors;
  final double gradientWidth;
  final double secondBorderWidth;
  final String? imageUrl;

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
          border: Border.all(color: const Color(0xFFECE7DC), width: secondBorderWidth),
        ),
        clipBehavior: Clip.hardEdge,
        child: ClipOval(
          child: imageUrl == null
              ? const AppImageErrorWidget()
              : AppCachedNetImage(
                  imageUrl: imageUrl!,
                ),
        ),
      ),
    );
  }
}
