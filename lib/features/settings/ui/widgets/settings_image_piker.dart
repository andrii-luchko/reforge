import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/settings/domain/enum/profile_settings.dart';

import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/painters/dashed_border_painter.dart';
import 'package:reforge/shared/app_cached_net_image.dart';

import 'package:reforge/shared/uikit/buttons/icon_button.dart';

import 'package:reforge/shared/uikit/buttons/thirty_button.dart';

class SettingsImagePicker extends StatelessWidget {
  const SettingsImagePicker({required this.onPressed, this.imageUrl, super.key});

  final VoidCallback onPressed;
  final String? imageUrl;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      children: [
        CustomPaint(
          painter: DashedBorderPainter(color: appTheme.beige700, strokeWidth: 1, radius: 20),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: .center,
              children: [
                if (imageUrl != null) AppCachedNetImage(imageUrl: imageUrl!),
                Center(
                  child: AppIconButton(
                    iconAsset: ProfileSettings.image.icon,
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        ),

        ThirtyButton(
          text: ProfileSettings.image.title(t),
          onPressed: onPressed,
        ),
      ],
    );
  }
}
