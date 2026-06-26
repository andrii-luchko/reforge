import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/active_workout/ui/widgets/active_workout_app_bar.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_dialogs.dart';
import 'package:reforge/features/workout_flow/controllers/workout_flow_cubit.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:toastification/toastification.dart';

class ActiveWorkoutShell extends StatefulWidget {
  const ActiveWorkoutShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ActiveWorkoutShell> createState() => _ActiveWorkoutShellState();
}

class _ActiveWorkoutShellState extends State<ActiveWorkoutShell> {
  /// Syncs elapsed duration to Drift every 10 seconds to survive force-kills.
  Timer? _durationSyncTimer;

  static const _syncInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    final timerCubit = context.read<TimerCubit>();
    final flowCubit = context.read<WorkoutFlowCubit>();

    // If restoring a session, initialise the timer with the previously saved duration
    if (flowCubit.state.isRestoredSession) {
      // TimerCubit counts from 0 by default; we pre-load the accumulated value.
      // We stop the timer first in case it was already running (shell rebuild),
      // then restart it from the restored position.
      timerCubit
        ..stopTimer()
        ..startTimerFrom(flowCubit.state.restoredDurationSec);
    } else {
      timerCubit.startTimer();
    }

    // Persist elapsed duration every 10 s so we don't lose it on force-kill
    _durationSyncTimer = Timer.periodic(_syncInterval, (_) {
      final elapsed = context.read<TimerCubit>().state.duration;
      context.read<WorkoutFlowCubit>().syncDuration(elapsed);
    });
  }

  @override
  void dispose() {
    _durationSyncTimer?.cancel();
    super.dispose();
  }

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
    return MultiBlocListener(
      listeners: [
        BlocListener<WorkoutFlowCubit, WorkoutFlowState>(
          listener: (context, state) {
            if (state.error == null) return;
            toastification.showErrorToast(state.error!, context);
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
              unawaited(context.read<UserCubit>().refreshUser());
              return;
            }

            if (flowState.isCompleted) {
              final summary = flowState.summary;
              if (summary == null) {
                const HomePageRoute().go(context);
              } else {
                // Navigate based on whether there are milestones
                if (summary.earnedMilestones.isNotEmpty) {
                  const WorkoutAchievementPageRoute(milestoneIndex: 0).go(context);
                } else {
                  const WorkoutSummaryPageRoute().go(context);
                }
              }
              unawaited(context.read<UserCubit>().refreshUser());
              return;
            }

            final currentExercise = flowState.currentExercise;

            if (currentExercise == null) return;

            ActiveWorkoutPageRoute(
              exerciseId: currentExercise.exerciseDetails.id,
            ).go(context);
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
              onRestTimerPressed: () {
                unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.workoutRestTimerClick));
                unawaited(WorkoutDialogs.restTimerDialog(context));
              },
            ),

            body: widget.child,
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
