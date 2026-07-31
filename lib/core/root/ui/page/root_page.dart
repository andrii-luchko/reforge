import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/features/workout_session/controllers/workout_restore_cubit.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/two_options_dialog_template.dart';
import 'package:reforge/shared/uikit/app_bottom_bar.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:toastification/toastification.dart';

class RootPage extends StatefulWidget {
  const RootPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // React to the restore cubit: show dialog on pending, navigate on restored.
        BlocListener<WorkoutRestoreCubit, WorkoutRestoreState>(
          listener: (ctx, restoreState) {
            switch (restoreState) {
              case WorkoutRestorePending():
                _showRestoreDialog(ctx, restoreState);
              case WorkoutRestoreRestored(:final resumeProgramExerciseId):
                ActiveExercisePageRoute(programExerciseId: resumeProgramExerciseId).go(ctx);
              case WorkoutRestoreError(:final message):
                toastification.showErrorToast(message, ctx);
              default:
                break;
            }
          },
        ),
      ],
      child: Stack(
        alignment: .bottomCenter,
        children: [
          widget.navigationShell,
          AppBottomBar(
            navigationShell: widget.navigationShell,
          ),
          const Positioned.fill(child: WorkoutRestoreLoader()),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, WorkoutRestorePending pending) {
    unawaited(
      AppDialog.show<bool?>(
        barrierDismissible: false,
        context,
        child: TwoOptionsDialog(
          title: 'Continue Workout?',
          rightButtonLabel: 'Continue',
          onRightOptionPressed: context.read<WorkoutRestoreCubit>().restoreSession,
          leftButtonLabel: t.common.cancel_button,
          onLeftOptionPressed: context.read<WorkoutRestoreCubit>().abandonSession,
          contentBuilder: (context) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'You have an unfinished workout session. Would you like to pick up where you left off?',
              textAlign: TextAlign.center,
              style: bodyLRegular.copyWith(color: context.appTheme.beige600),
            ),
          ),
        ),
      ),
    );
  }
}

class WorkoutRestoreLoader extends StatelessWidget {
  const WorkoutRestoreLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkoutRestoreCubit, WorkoutRestoreState, bool>(
      selector: (state) => state is WorkoutRestoreRestoring,
      builder: (context, isRestoring) {
        return isRestoring ? const ScreenLoadingIndicator() : const SizedBox.shrink();
      },
    );
  }
}
