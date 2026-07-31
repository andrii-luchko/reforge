import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/utils/toasts/show_toast.dart';
import 'package:reforge/core/timer/controller/timer_cubit.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/pages/regular_exercise_page.dart';
import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/domain/entities/running_exercise_config.dart';
import 'package:reforge/features/running/ui/pages/running_exercise_host.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:toastification/toastification.dart';

class ActiveExerciseHost extends StatelessWidget {
  const ActiveExerciseHost({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
          listenWhen: (previous, current) => !previous.isSubmitted && current.isSubmitted,
          listener: (context, state) async {
            final duration = context.read<TimerCubit>().state.duration;
            await context.read<WorkoutSessionFlowCubit>().nextExercise(duration);
          },
        ),
        BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
          listenWhen: (previous, current) => previous.setValidationError != current.setValidationError,
          listener: (context, state) {
            if (state.setValidationError case final error?) {
              toastification.showErrorToast(error, context);
            }
          },
        ),
        BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
          listenWhen: (previous, current) => previous.error != current.error,
          listener: (context, state) {
            if (state.error case final error?) {
              toastification.showErrorToast(error, context);
            }
          },
        ),
      ],
      child: BlocBuilder<ActiveExerciseCubit, ActiveExerciseState>(
        buildWhen: (previous, current) =>
            previous.effectiveExercise.id != current.effectiveExercise.id ||
            previous.session.isSwapped != current.session.isSwapped,
        builder: (context, state) {
          final cubit = context.read<ActiveExerciseCubit>();
          if (!cubit.isRunningExercise) {
            return RegularExercisePage(
              key: ValueKey(state.effectiveExercise.id),
            );
          }

          final config = RunningExerciseConfig(
            workoutSessionId: state.session.workoutSessionId,
            workoutProgramExerciseId: cubit.programExercise.id,
            exercise: state.effectiveExercise,
            segments: state.session.isSwapped ? const [] : cubit.programExercise.segments,
          );
          return _RunningExerciseBranch(
            key: ValueKey(state.effectiveExercise.id),
            config: config,
          );
        },
      ),
    );
  }
}

class _RunningExerciseBranch extends StatelessWidget {
  const _RunningExerciseBranch({required this.config, super.key});

  final RunningExerciseConfig config;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = di.getIt<RunningTrackerCubit>(param1: config);
            unawaited(cubit.init());
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => di.getIt<RunningSetSyncCubit>(param1: config)..init(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ActiveExerciseCubit, ActiveExerciseState>(
            listenWhen: (previous, current) => previous.isLoading && !current.isLoading,
            listener: (context, state) {
              final syncState = context.read<RunningSetSyncCubit>().state;
              context.read<ActiveExerciseCubit>().replaceSetsFromExternalSource(
                sets: syncState.sets,
                isSending: syncState.isSending,
              );
            },
          ),
          BlocListener<RunningSetSyncCubit, RunningSetSyncState>(
            listener: (context, syncState) {
              final activeExerciseCubit = context.read<ActiveExerciseCubit>();
              if (activeExerciseCubit.state.isLoading) return;
              activeExerciseCubit.replaceSetsFromExternalSource(
                sets: syncState.sets,
                isSending: syncState.isSending,
              );
            },
          ),
        ],
        child: RunningExerciseHost(
          onExerciseFinished: context.read<ActiveExerciseCubit>().finishExercise,
        ),
      ),
    );
  }
}
