import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.settings_suggest_rounded,
                size: 80,
                color: theme.beige500,
              ),
              const SizedBox(height: 24),
              Text(
                'Permission Required',
                style: titleH3Regular.copyWith(color: theme.beige100),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Tracking your run requires access to device sensors. Please open settings and grant the required permissions.',
                style: bodyMRegular.copyWith(color: theme.beige400),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Open Settings',
                onPressed: () => openAppSettings(),
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                text: 'Cancel',
                onPressed: () => context.read<RunningTrackerCubit>().cancelPermissionRequest(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
