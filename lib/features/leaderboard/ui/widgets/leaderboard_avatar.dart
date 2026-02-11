import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/shared/app_image_wrapper.dart';

class LeaderBoardAvatar extends StatelessWidget {
  const LeaderBoardAvatar({
    required this.size,
    required this.borderGradientColors,
    this.imageUrl,
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
          color: context.appTheme.beige200,
          border: Border.all(
            color: const Color(0xFFECE7DC),
            width: secondBorderWidth,
          ),
        ),

        child: ClipOval(child: AppImageWrapper(imageUrl: imageUrl)),
      ),
    );
  }
}
