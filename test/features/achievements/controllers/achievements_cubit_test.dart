import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';
import 'package:reforge/features/achievements/data/repositories/achievements_repository.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

import '../../../core/user/mocks/mock_user_cubit.dart';

class _MockAchievementsRepository extends Mock implements AchievementsRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

OnboardedUser _user(Faction faction, {String? email}) => OnboardedUser(
  id: 1,
  email: email,
  measurementSystem: MeasurementSystem.metric,
  factionId: faction.id,
  birthDate: DateTime(1990),
  workoutsPerWeek: 3,
);

void main() {
  test('tracks faction changes, ignores unrelated fields, and clears on logout', () async {
    final repository = _MockAchievementsRepository();
    final analytics = _MockAnalyticsService();
    final userCubit = MockUserCubit();
    final changes = StreamController<OnboardedUser?>.broadcast();
    final initialUser = _user(Faction.gakki, email: 'old@example.com');
    when(() => userCubit.currentOnboardedUser).thenReturn(initialUser);
    when(() => userCubit.onboardedUserChanges).thenAnswer((_) => changes.stream);

    final cubit = AchievementsCubit(repository, analytics, userCubit);
    expect(cubit.state.selectedFaction, Faction.gakki);

    changes.add(initialUser.copyWith(email: 'new@example.com'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.selectedFaction, Faction.gakki);

    changes.add(_user(Faction.gyohyo));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.selectedFaction, Faction.gyohyo);

    changes.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const AchievementsState());

    await cubit.close();
    await changes.close();
  });
}
