import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/badge_image.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class AudioHintDialog extends StatelessWidget {
  const AudioHintDialog({super.key});

  static Future<void> show(BuildContext context) {
    return AppDialog.show<void>(
      context,
      child: const AudioHintDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Workout Cues',
            style: subheadH2Medium.copyWith(color: theme.beige100),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 160,
            child: BadgeImage.asset(
              asset: Assets.images.png.magnificHammer.path,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Follow the Hammer',
            style: subheadH1Medium.copyWith(color: theme.beige100),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "The hammer sound will guide you through each interval. One strike means it's time to switch pace, while three strikes indicate you've completed the workout.",
            style: bodyLRegular.copyWith(color: theme.beige600),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            text: 'Got it',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
