import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/exceptions/app_exception.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_session/domain/repositories/workout_session_repository.dart';

part 'exercise_swap_cubit.freezed.dart';
part 'exercise_swap_state.dart';

@injectable
class ExerciseSwapCubit extends Cubit<ExerciseSwapState> {
  ExerciseSwapCubit(
    this._exerciseRepository,
    this._workoutRepository,
    @factoryParam this.requestContext,
  ) : super(const ExerciseSwapState());

  static const searchDebounce = Duration(milliseconds: 350);
  static const pageLimit = 20;

  final ExerciseSessionRepository _exerciseRepository;
  final WorkoutSessionRepository _workoutRepository;
  final ExerciseSwapRequestContext requestContext;

  Timer? _searchTimer;
  var _searchRevision = 0;
  var _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _loadFirst(++_searchRevision);
  }

  void searchChanged(String value) {
    _searchTimer?.cancel();
    final revision = ++_searchRevision;
    emit(state.copyWith(query: value, selectedExerciseId: null, error: null));
    _searchTimer = Timer(searchDebounce, () => unawaited(_loadFirst(revision)));
  }

  void factionChanged(int? factionId) {
    if (state.factionId == factionId) return;
    _searchTimer?.cancel();
    final revision = ++_searchRevision;
    emit(state.copyWith(factionId: factionId, selectedExerciseId: null, error: null));
    unawaited(_loadFirst(revision));
  }

  Future<void> retry() => _loadFirst(++_searchRevision);

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final revision = _searchRevision;
    final nextPage = state.page + 1;
    final query = _normalizedQuery(state.query);
    final factionId = state.factionId;
    emit(state.copyWith(isLoadingMore: true, error: null));

    final result = await _exerciseRepository.searchSwapExercises(
      search: query,
      factionId: factionId,
      page: nextPage,
    );

    if (isClosed || revision != _searchRevision) return;
    switch (result) {
      case Success(value: final resultPage):
        final merged = <int, ExerciseDetailsEntity>{
          for (final exercise in state.exercises) exercise.id: exercise,
          for (final exercise in _withoutCurrentExercise(resultPage.exercises)) exercise.id: exercise,
        };
        emit(
          state.copyWith(
            exercises: merged.values.toList(),
            page: resultPage.pagination.page,
            pages: resultPage.pagination.pages,
            isLoadingMore: false,
            error: null,
          ),
        );

      case Failure(:final error):
        emit(state.copyWith(isLoadingMore: false, error: error.toString()));
    }
  }

  void selectExercise(int exerciseId) {
    if (state.isSwapping || !state.exercises.any((exercise) => exercise.id == exerciseId)) return;
    emit(state.copyWith(selectedExerciseId: state.selectedExerciseId == exerciseId ? null : exerciseId, error: null));
  }

  Future<AppliedExerciseSwap?> swapSelected() async {
    final exercise = state.selectedExercise;
    if (state.isSwapping || exercise == null || exercise.id == requestContext.currentExerciseId) return null;

    emit(state.copyWith(swappingExerciseId: exercise.id, error: null));
    final result = await _exerciseRepository.swapExercise(
      workoutExerciseSessionId: requestContext.workoutExerciseSessionId,
      swappedExerciseId: exercise.id,
      system: requestContext.measurementSystem,
    );

    if (isClosed) return null;
    final applied = switch (result) {
      Success(value: final session) => _confirmedSwap(session, exercise),
      Failure(:final error) when _isAmbiguousFailure(error) => await _reconcileSwap(exercise),
      Failure() => null,
    };

    if (applied != null) {
      emit(state.copyWith(swappingExerciseId: null, error: null));
      return applied;
    }

    final error = switch (result) {
      Failure(:final error) => error,
      Success() => AppException('The server did not confirm the exercise swap'),
    };
    emit(state.copyWith(swappingExerciseId: null, error: error.toString()));
    return null;
  }

  Future<void> _loadFirst(int revision) async {
    if (isClosed || revision != _searchRevision) return;

    final query = _normalizedQuery(state.query);
    final factionId = state.factionId;
    emit(
      state.copyWith(
        exercises: const [],
        selectedExerciseId: null,
        page: 1,
        pages: 1,
        isLoading: true,
        isLoadingMore: false,
        error: null,
      ),
    );

    final result = await _exerciseRepository.searchSwapExercises(
      search: query,
      factionId: factionId,
    );

    if (isClosed || revision != _searchRevision) return;
    switch (result) {
      case Success(value: final resultPage):
        emit(
          state.copyWith(
            exercises: _withoutCurrentExercise(resultPage.exercises),
            page: resultPage.pagination.page,
            pages: resultPage.pagination.pages,
            isLoading: false,
            error: null,
          ),
        );

      case Failure(:final error):
        emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  AppliedExerciseSwap? _confirmedSwap(
    WorkoutExerciseSessionEntity session,
    ExerciseDetailsEntity exercise,
  ) {
    if (session.id != requestContext.workoutExerciseSessionId || session.swappedExerciseId != exercise.id) {
      return null;
    }
    return AppliedExerciseSwap(session: session, exercise: exercise);
  }

  Future<AppliedExerciseSwap?> _reconcileSwap(ExerciseDetailsEntity exercise) async {
    final result = await _workoutRepository.getWorkoutSessionDetails(requestContext.workoutSessionId);
    if (result case Success(value: final details?)) {
      final dto = details.workoutSessions?.firstWhereOrNull(
        (session) => session.id == requestContext.workoutExerciseSessionId,
      );
      if (dto == null) return null;
      return _confirmedSwap(dto.toEntity(requestContext.measurementSystem), exercise);
    }
    return null;
  }

  bool _isAmbiguousFailure(Exception error) {
    if (error is! AppNetworkException) return false;
    if ((error.statusCode ?? 0) >= 500) return true;

    final original = error.originalError;
    if (original is! DioException) return error.statusCode == null;
    return switch (original.type) {
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.unknown => true,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.badCertificate ||
      DioExceptionType.badResponse ||
      DioExceptionType.cancel => false,
    };
  }

  List<ExerciseDetailsEntity> _withoutCurrentExercise(List<ExerciseDetailsEntity> exercises) {
    return exercises.where((exercise) => exercise.id != requestContext.currentExerciseId).toList();
  }

  String? _normalizedQuery(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  @override
  Future<void> close() async {
    _searchTimer?.cancel();
    return super.close();
  }
}
