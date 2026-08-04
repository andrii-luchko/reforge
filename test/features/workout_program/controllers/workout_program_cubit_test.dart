import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/controllers/workout_program_cubit.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/workout_program_repository.dart';

void main() {
  test('init loads the current program day from the user session', () async {
    final repository = _FakeWorkoutProgramRepository();
    final cubit = WorkoutProgramCubit(
      repository,
      _FakeUserSessionService(_onboardedUser(currentProgramDayId: 42)),
    );

    await cubit.init();

    expect(repository.requestedDayIds, [42]);
    expect(cubit.state.programDay?.id, 42);
    expect(cubit.state.isLoading, isFalse);

    await cubit.close();
  });

  test('loadProgramDay replaces the preview without starting a workout session', () async {
    final repository = _FakeWorkoutProgramRepository();
    final cubit = WorkoutProgramCubit(
      repository,
      _FakeUserSessionService(_onboardedUser(currentProgramDayId: 1)),
    );

    await cubit.loadProgramDay(7);

    expect(repository.requestedDayIds, [7]);
    expect(cubit.state.programDay?.id, 7);

    await cubit.close();
  });
}

class _FakeWorkoutProgramRepository implements WorkoutProgramRepository {
  final List<int> requestedDayIds = [];

  @override
  Future<Result<ProgramDayEntity?>> getWorkoutByDay(int day) async {
    requestedDayIds.add(day);
    return Result.success(
      ProgramDayEntity(
        id: day,
        name: 'Day $day',
        dayNumber: day,
        programExercises: const [],
      ),
    );
  }
}

class _FakeUserSessionService implements UserSessionService {
  _FakeUserSessionService(this.currentUser);

  @override
  User? currentUser;

  @override
  int? get currentUserId => currentUser?.id;

  @override
  Future<void> clearUser() async {
    currentUser = null;
  }

  @override
  Future<void> saveUser(User user) async {
    currentUser = user;
  }
}

User _onboardedUser({required int currentProgramDayId}) {
  return User.onboarded(
    id: 1,
    measurementSystem: MeasurementSystem.metric,
    factionId: 1,
    birthDate: DateTime(1990),
    workoutsPerWeek: 3,
    currentProgramDayId: currentProgramDayId,
  );
}
