import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/workout_program_repository.dart';

part 'workout_program_cubit.freezed.dart';
part 'workout_program_state.dart';

@lazySingleton
class WorkoutProgramCubit extends Cubit<WorkoutProgramState> {
  WorkoutProgramCubit(
    this._repository,
    this._userSessionService,
  ) : super(const WorkoutProgramState());

  final WorkoutProgramRepository _repository;
  final UserSessionService _userSessionService;

  Future<void> init() async {
    final userCurrentDay = _userSessionService.currentUser?.map(
      newUser: (_) => null,
      onboarded: (user) => user.currentProgramDayId,
    );
    final currentWeekDay = DateTime.now().weekday;
    final currentDay = userCurrentDay ?? currentWeekDay;

    logger.d(
      'WorkoutProgramCubit.init — userCurrentDay: $userCurrentDay, '
      'weekday: $currentWeekDay, selected: $currentDay',
    );

    if (currentDay == state.programDay?.id) return;
    await loadProgramDay(currentDay);
  }

  Future<void> loadProgramDay(int programDayId) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getWorkoutByDay(programDayId);
    switch (result) {
      case Success(value: final programDay):
        emit(state.copyWith(isLoading: false, programDay: programDay));
      case Failure(:final error):
        emit(
          state.copyWith(
            isLoading: false,
            programDay: null,
            error: error.toString(),
          ),
        );
    }
  }
}
