import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({required this.assetPath, required this.text, required this.title, this.onPressed, super.key});

  final String assetPath;
  final String title;
  final String? text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final borderRadius = BorderRadius.circular(20);
    return Skeleton.leaf(
      child: PressableAnimation(
        scaleAmount: 0.99,
        onTap: onPressed,
        child: Container(
          padding: const .all(16),
          decoration: BoxDecoration(
            color: appTheme.beige900,
            border: Border.all(color: appTheme.strokeCard),
            borderRadius: borderRadius,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                assetPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(appTheme.beige100, .srcIn),
              ),

              const SizedBox(width: 10),

              Flexible(
                fit: .tight,
                child: Text(
                  title,
                  style: subheadH3Medium.copyWith(color: appTheme.beige100),
                  overflow: .ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 16),
              if (text != null)
                Expanded(
                  child: Text(
                    text!,
                    textAlign: TextAlign.end,
                    style: bodyLRegular.copyWith(
                      color: appTheme.beige700,
                    ),
                    overflow: .ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
