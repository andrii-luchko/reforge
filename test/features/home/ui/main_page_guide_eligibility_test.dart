import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/home/ui/guide/main_page_guide_eligibility.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

import '../../../helpers/test_setup.dart';

final _user = OnboardedUser(
  id: 71,
  email: 'guide@example.com',
  measurementSystem: MeasurementSystem.metric,
  factionId: 1,
  birthDate: DateTime(1990, 1, 15),
  workoutsPerWeek: 3,
  userName: 'Guide Tester',
  bodyWeight: 75,
);

void main() {
  initTestTranslations();

  test('accepts approved new-user fallback stats', () {
    final stats = UserStats.newUser();
    final state = HomeState(
      user: _user,
      rank: RankEntity.mockWith(t),
      statsMap: {StatsPeriod.lastWeek: stats},
    );

    expect(canStartMainPageGuide(state), isTrue);
  });

  test('rejects loading and incomplete Home states', () {
    final stats = UserStats.newUser();
    final readyState = HomeState(
      user: _user,
      rank: RankEntity.mockWith(t),
      statsMap: {StatsPeriod.lastWeek: stats},
    );

    expect(
      canStartMainPageGuide(readyState.copyWith(isLoading: true)),
      isFalse,
    );
    expect(
      canStartMainPageGuide(readyState.copyWith(user: null)),
      isFalse,
    );
    expect(
      canStartMainPageGuide(readyState.copyWith(rank: null)),
      isFalse,
    );
    expect(
      canStartMainPageGuide(readyState.copyWith(statsMap: {})),
      isFalse,
    );
  });
}
