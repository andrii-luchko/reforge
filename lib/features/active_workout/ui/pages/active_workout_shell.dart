import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';

import 'package:reforge/features/workout_congratulations/controllers/workout_congratulations/workout_congratulations_cubit.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/features/workout_common/models/workout_congratulations_content.dart';
import 'package:reforge/features/active_workout/ui/widgets/active_workout_app_bar.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_dialogs.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:toastification/toastification.dart';

class ActiveWorkoutShell extends StatelessWidget {
  const ActiveWorkoutShell({
    required this.child,
    super.key,
  });

  final Widget child;

  Future<void> onClosePressed(BuildContext context) async {
    final leave = await WorkoutDialogs.confirmWorkoutLeave(context);

    if ((leave ?? false) && context.mounted) {
      context.read<TimerCubit>().pauseTimer();

      final duration = context.read<TimerCubit>().state.duration;

      await context.read<WorkoutFlowCubit>().cancelWorkout(duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<TimerCubit>().startTimer();

    return MultiBlocListener(
      listeners: [
        BlocListener<WorkoutFlowCubit, WorkoutFlowState>(
          listener: (context, state) {
            if (state.error != null) {
              toastification.showErrorToast(state.error!, context);
            }
          },
        ),

        BlocListener<WorkoutFlowCubit, WorkoutFlowState>(
          listenWhen: (previous, current) {
            if (previous.sessionStatus != current.sessionStatus) return true;

            if (previous.currentExerciseIndex != current.currentExerciseIndex) return true;

            return false;
          },
          listener: (context, flowState) {
            if (flowState.isCanceled) {
              const HomePageRoute().go(context);
              return;
            }

            if (flowState.isCompleted) {
              final summary = flowState.summary;
              if (summary == null) {
                const HomePageRoute().go(context);
              } else {
                context.read<WorkoutCongratulationsCubit>().initialize(
                  contentItems: [
                    WorkoutCongratulationsContent.summary(WorkoutSummaryContent.fromSessionSummary(summary)),
                  ],
                );
                const WorkoutCongratulationsPageRoute().go(context);
              }
              return;
            }

            if (flowState.currentExercise != null) {
              ActiveWorkoutPageRoute(
                exerciseId: flowState.currentExercise!.exerciseDetails.id,
              ).go(context);
            }
          },
        ),
      ],
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            appBar: ActiveWorkoutAppBar(
              onClosePressed: () async => onClosePressed(context),
              onTimerPressed: () => WorkoutDialogs.restTimerDialog(context),
            ),

            body: child,
          ),
          const WorkoutFlowLoader(),
        ],
      ),
    );
  }
}

class WorkoutFlowLoader extends StatelessWidget {
  const WorkoutFlowLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkoutFlowCubit, WorkoutFlowState, bool>(
      selector: (state) => state.isLoading,
      builder: (context, isLoading) {
        return isLoading ? const ScreenLoadingIndicator() : const SizedBox.shrink();
      },
    );
  }
}
