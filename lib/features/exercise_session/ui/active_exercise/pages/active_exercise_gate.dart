import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/pages/active_exercise_host.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/domain/entities/active_workout_exercise_context.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:reforge/shared/uikit/states/no_workout_error_widget.dart';

class ActiveExerciseGate extends StatefulWidget {
  const ActiveExerciseGate({required this.programExerciseId, super.key});

  final int programExerciseId;

  @override
  State<ActiveExerciseGate> createState() => _ActiveExerciseGateState();
}

class _ActiveExerciseGateState extends State<ActiveExerciseGate> {
  ProgramExerciseEntity? _programExercise;
  Future<Result<ActiveWorkoutExerciseContext>>? _contextFuture;
  bool _isInvalidRoute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_contextFuture != null || _isInvalidRoute) return;

    final flowCubit = context.read<WorkoutSessionFlowCubit>();
    final flowState = flowCubit.state;
    final programExercise = flowState.programDay?.programExercises.firstWhereOrNull(
      (exercise) => exercise.id == widget.programExerciseId,
    );
    if (flowState.workoutSessionId == null || programExercise == null) {
      _isInvalidRoute = true;
      return;
    }

    _programExercise = programExercise;
    _contextFuture = flowCubit.ensureExerciseSession(programExercise);
  }

  void _retry() {
    final programExercise = _programExercise;
    if (programExercise == null) return;
    setState(() {
      _contextFuture = context.read<WorkoutSessionFlowCubit>().retryEnsureExerciseSession(programExercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInvalidRoute) return const NoWorkoutErrorWidget();
    final future = _contextFuture;
    if (future == null) return const ScreenLoadingIndicator();

    return FutureBuilder<Result<ActiveWorkoutExerciseContext>>(
      future: future,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null) {
          if (snapshot.hasError) {
            return _ExerciseSessionError(message: snapshot.error.toString(), onRetry: _retry);
          }
          return const ScreenLoadingIndicator();
        }

        return switch (result) {
          Failure(:final error) => _ExerciseSessionError(message: error.toString(), onRetry: _retry),
          Success(value: final exerciseContext) => _buildExercise(exerciseContext),
        };
      },
    );
  }

  Widget _buildExercise(ActiveWorkoutExerciseContext exerciseContext) {
    final flowState = context.read<WorkoutSessionFlowCubit>().state;
    final restoredSets = flowState.restoredSets[exerciseContext.programExercise.id];
    final initialSets = restoredSets ?? (exerciseContext.session.sets.isEmpty ? null : exerciseContext.session.sets);

    return BlocProvider(
      key: ValueKey(exerciseContext.session.id),
      create: (_) {
        final cubit = di.getIt<ActiveExerciseCubit>(param1: exerciseContext);
        unawaited(cubit.initialize(restoredSets: initialSets));
        return cubit;
      },
      child: const ActiveExerciseHost(),
    );
  }
}

class _ExerciseSessionError extends StatelessWidget {
  const _ExerciseSessionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(message, style: subheadH1Medium, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                PrimaryButton(text: t.camera_detection.tryAgain, onPressed: onRetry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
