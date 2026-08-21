import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/extensions/duration_extensions.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/badge_image.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class WalkAudioHintDialog extends StatelessWidget {
  const WalkAudioHintDialog({required this.walkDuration, super.key});

  final Duration walkDuration;

  static Future<void> show(BuildContext context, Duration walkDuration) {
    return AppDialog.show<void>(
      context,
      child: WalkAudioHintDialog(
        walkDuration: walkDuration,
      ),
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
            t.running.audio_hint.next_interval,
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
            t.running.audio_hint.recovery_walk,
            style: subheadH1Medium.copyWith(color: theme.beige100),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: bodyLRegular.copyWith(color: theme.beige600),
              children: [
                TextSpan(text: t.running.audio_hint.slow_down_part1),
                TextSpan(
                  text: '\n${walkDuration.toDigital()}\n',
                  style: subheadH2Medium.copyWith(
                    color: theme.orange400,
                    fontSize: 16,
                  ),
                ),
                TextSpan(text: t.running.audio_hint.slow_down_part2),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: t.running.audio_hint.got_it,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
