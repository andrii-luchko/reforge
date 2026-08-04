import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/router/routes.dart';
import 'package:reforge/app/utils/helpers/keyboard_visibility_provider.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/exercise_session/ui/widgets/workout_dialogs.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/ui/active_workout/widgets/active_workout_app_bar.dart';
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

class _ActiveWorkoutShellState extends State<ActiveWorkoutShell> with WidgetsBindingObserver {
  /// Syncs elapsed duration to Drift every 10 seconds to survive force-kills.
  Timer? _durationSyncTimer;

  static const _syncInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final timerCubit = context.read<TimerCubit>();
    final flowCubit = context.read<WorkoutSessionFlowCubit>();

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
      final elapsed = timerCubit.state.duration;
      context.read<WorkoutSessionFlowCubit>().syncDuration(elapsed);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _durationSyncTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force an immediate timer update instead of waiting up to 1 second
      // for the next tick. Without this, the displayed time can lag briefly.
      final timerCubit = context.read<TimerCubit>()..onAppResumed();
      context.read<WorkoutSessionFlowCubit>().syncDuration(timerCubit.state.duration);
      logger.d('ActiveWorkoutShell: foreground duration synced');
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      final duration = context.read<TimerCubit>().state.duration;
      context.read<WorkoutSessionFlowCubit>().syncDuration(duration);
      logger.d('ActiveWorkoutShell: background duration synced state=${state.name}');
    }
  }

  Future<void> onClosePressed(BuildContext context) async {
    final leave = await WorkoutDialogs.confirmWorkoutLeave(context);

    if ((leave ?? false) && context.mounted) {
      context.read<TimerCubit>().pauseTimer();

      final duration = context.read<TimerCubit>().state.duration;

      await context.read<WorkoutSessionFlowCubit>().cancelWorkout(duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityProvider(
      child: MultiBlocListener(
        listeners: [
          BlocListener<WorkoutSessionFlowCubit, WorkoutSessionFlowState>(
            listener: (context, state) {
              if (state.error == null) return;
              toastification.showErrorToast(state.error!, context);
            },
          ),

          BlocListener<WorkoutSessionFlowCubit, WorkoutSessionFlowState>(
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
                  const WorkoutCongratulationsPageRoute().go(context);
                }
                unawaited(context.read<UserCubit>().refreshUser());
                return;
              }

              final currentExercise = flowState.currentExercise;

              if (currentExercise == null) return;

              ActiveExercisePageRoute(
                executionKey: currentExercise.executionKey,
              ).go(context);
            },
          ),
        ],
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: true,
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
            const WorkoutSessionLoader(),
          ],
        ),
      ),
    );
  }
}

class WorkoutSessionLoader extends StatelessWidget {
  const WorkoutSessionLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkoutSessionFlowCubit, WorkoutSessionFlowState, bool>(
      selector: (state) => state.isLoading,
      builder: (context, isLoading) {
        return isLoading ? const ScreenLoadingIndicator() : const SizedBox.shrink();
      },
    );
  }
}
