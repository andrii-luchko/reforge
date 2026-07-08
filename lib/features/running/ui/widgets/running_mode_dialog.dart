import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';

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
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DefaultDialogHeader(title: t.running.mode.title),
          ),

          const SizedBox(height: 24),

          _RunningModeOption(
            icon: Icons.directions_run_rounded,
            title: t.running.mode.outdoor_run,

            mode: RunningMode.gps,
            onTap: (mode) => _onModeSelected(context, mode),
          ),

          const SizedBox(height: 12),

          _RunningModeOption(
            icon: Icons.fitness_center_rounded,
            title: t.running.mode.treadmill_run,

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
                              t.running.mode.soon,
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
