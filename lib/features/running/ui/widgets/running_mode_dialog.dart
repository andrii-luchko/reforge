import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/badge_image.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';

class RunningModeDialog extends StatelessWidget {
  const RunningModeDialog({super.key});

  static Future<RunningMode?> show(BuildContext context) {
    return AppDialog.show<RunningMode?>(
      context,
      child: const RunningModeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: .only(right: 10),
            child: DefaultDialogHeader(title: 'Running'),
          ),

          const SizedBox(height: 24),

          _RunningModeOption(
            icon: Icons.directions_run_rounded,
            title: 'Outdoor Run',

            mode: RunningMode.gps,
            onTap: (mode) => _onModeSelected(context, mode),
          ),

          const SizedBox(height: 12),

          _RunningModeOption(
            icon: Icons.fitness_center_rounded,
            title: 'Treadmill run',

            mode: RunningMode.pedometer,
            onTap: (mode) => _onModeSelected(context, mode),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _onModeSelected(BuildContext context, RunningMode mode) async {
    Navigator.of(context).pop(mode);
  }
}

class _RunningModeOption extends StatelessWidget {
  const _RunningModeOption({
    required this.icon,
    required this.title,
    required this.mode,
    required this.onTap,
    // ignore: unused_element_parameter
    this.isDisabled = false,
  });

  final IconData icon;
  final String title;

  final RunningMode mode;
  final bool isDisabled;
  final void Function(RunningMode) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return AnimatedOpacity(
      opacity: isDisabled ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: PressableAnimation(
        scaleAmount: 0.98,
        onTap: isDisabled ? null : () => onTap(mode),
        child: Container(
          padding: const .all(16),
          decoration: BoxDecoration(
            border: .all(color: context.appTheme.strokeCard),
            borderRadius: .circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.beige100, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: subheadH3Medium.copyWith(color: theme.beige100),
                        ),
                        if (isDisabled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: theme.beige800,
                            ),
                            child: Text(
                              'Soon',
                              style: bodySRegular.copyWith(color: theme.beige500),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
