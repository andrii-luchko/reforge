import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';

class RunningPermissionDeniedPage extends StatelessWidget {
  const RunningPermissionDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return DefaultBackground(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.settings_suggest_rounded,
                size: 90,
                color: theme.beige500,
              ),
              const SizedBox(height: 24),
              Text(
                t.running.permission.title,
                style: subheadH1Medium.copyWith(
                  color: theme.beige100,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                t.running.permission.description,
                style: bodyLRegular.copyWith(color: theme.beige400),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                text: t.running.permission.open_settings,
                onPressed: () {
                  try {
                    unawaited(openAppSettings());
                    // ignore: avoid_catches_without_on_clauses
                  } catch (_) {}
                },
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                text: t.running.permission.cancel,
                onPressed: () => context.read<RunningTrackerCubit>().cancelPermissionRequest(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
