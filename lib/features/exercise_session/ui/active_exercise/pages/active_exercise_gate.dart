import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/controllers/active_exercise/active_exercise_cubit.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/pages/active_exercise_host.dart';
import 'package:reforge/features/workout_session/controllers/workout_session_flow_cubit.dart';
import 'package:reforge/features/workout_session/domain/entities/active_exercise_execution.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_exercise_spec.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/primary_button.dart';
import 'package:reforge/shared/uikit/default_background.dart';
import 'package:reforge/shared/uikit/screen_loading_indicator.dart';
import 'package:reforge/shared/uikit/states/no_workout_error_widget.dart';

class ActiveExerciseGate extends StatefulWidget {
  const ActiveExerciseGate({required this.executionKey, super.key});

  final String executionKey;

  @override
  State<ActiveExerciseGate> createState() => _ActiveExerciseGateState();
}

class _ActiveExerciseGateState extends State<ActiveExerciseGate> {
  WorkoutExerciseSpec? _spec;
  Future<Result<ActiveExerciseExecution>>? _contextFuture;
  bool _isInvalidRoute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_contextFuture != null || _isInvalidRoute) return;

    final flowCubit = context.read<WorkoutSessionFlowCubit>();
    final flowState = flowCubit.state;
    final spec = flowState.executionPlan?.exercises
        .where((exercise) => exercise.executionKey == widget.executionKey)
        .firstOrNull;
    if (flowState.workoutSessionId == null || spec == null) {
      _isInvalidRoute = true;
      return;
    }

    _spec = spec;
    _contextFuture = flowCubit.ensureExerciseSession(spec);
  }

  void _retry() {
    final spec = _spec;
    if (spec == null) return;
    setState(() {
      _contextFuture = context.read<WorkoutSessionFlowCubit>().retryEnsureExerciseSession(spec);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInvalidRoute) return const NoWorkoutErrorWidget();
    final future = _contextFuture;
    if (future == null) return const ScreenLoadingIndicator();

    return FutureBuilder<Result<ActiveExerciseExecution>>(
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
          Success(value: final execution) => _buildExercise(execution),
        };
      },
    );
  }

  Widget _buildExercise(ActiveExerciseExecution execution) {
    final flowState = context.read<WorkoutSessionFlowCubit>().state;
    final programExerciseId = execution.spec.workoutProgramExerciseId;
    final restoredSets = programExerciseId == null ? null : flowState.restoredSets[programExerciseId];
    final initialSets = restoredSets ?? (execution.session.sets.isEmpty ? null : execution.session.sets);

    return BlocProvider(
      key: ValueKey(execution.exerciseSessionId),
      create: (_) {
        final cubit = di.getIt<ActiveExerciseCubit>(param1: execution);
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
