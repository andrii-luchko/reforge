// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

OnboardedUser createUser({
  double? bodyWeight,
  MeasurementSystem measurementSystem = MeasurementSystem.metric,
  int factionId = 1,
  int? secondaryFactionId,
  List<int> specificDays = const [],
}) {
  return User.onboarded(
        id: 1,
        email: 'test@example.com',
        bodyWeight: bodyWeight,
        measurementSystem: measurementSystem,
        factionId: factionId,
        secondaryFactionId: secondaryFactionId,
        birthDate: DateTime(1990, 1, 15),
        workoutsPerWeek: 3,
        specificDays: specificDays,
        userName: 'John',
      )
      as OnboardedUser;
}

void main() {
  group('OnboardedUserX', () {
    group('displayedWeight', () {
      test('returns null when bodyWeight is null', () {
        final user = createUser(bodyWeight: null);
        expect(user.displayedWeight, isNull);
      });

      test('returns bodyWeight for metric system', () {
        final user = createUser(bodyWeight: 70);
        expect(user.displayedWeight, 70);
      });

      test('converts to pounds for imperial system', () {
        final user = createUser(
          bodyWeight: 70,
          measurementSystem: MeasurementSystem.imperial,
        );
        expect(user.displayedWeight, 154); // 70 kg -> ~154 lbs, truncated
      });
    });

    group('mainFaction', () {
      test('returns gakki for factionId 1', () {
        final user = createUser(factionId: 1);
        expect(user.mainFaction, Faction.gakki);
      });

      test('returns seiren for factionId 2', () {
        final user = createUser(factionId: 2);
        expect(user.mainFaction, Faction.seiren);
      });

      test('returns gyohyo for factionId 3', () {
        final user = createUser(factionId: 3);
        expect(user.mainFaction, Faction.gyohyo);
      });
    });

    group('secondaryFaction', () {
      test('returns faction for secondaryFactionId', () {
        final user = createUser(secondaryFactionId: 2);
        expect(user.secondaryFaction, Faction.seiren);
      });

      test('returns null when secondaryFactionId is null', () {
        final user = createUser(secondaryFactionId: null);
        expect(user.secondaryFaction, isNull);
      });
    });

    group('specificWeekDays', () {
      test('maps specificDays to WeekDay list', () {
        final user = createUser(specificDays: [1, 3, 5]);
        expect(user.specificWeekDays, [WeekDay.monday, WeekDay.wednesday, WeekDay.friday]);
      });

      test('filters out invalid values', () {
        final user = createUser(specificDays: [1, 0, 8, 3]);
        expect(user.specificWeekDays, [WeekDay.monday, WeekDay.wednesday]);
      });

      test('returns empty list when specificDays is empty', () {
        final user = createUser(specificDays: []);
        expect(user.specificWeekDays, isEmpty);
      });
    });

    group('factionsList', () {
      test('returns both factions when both set', () {
        final user = createUser(factionId: 1, secondaryFactionId: 2);
        expect(user.factionsList, [Faction.gakki, Faction.seiren]);
      });

      test('returns only main faction when secondary is null', () {
        final user = createUser(factionId: 1, secondaryFactionId: null);
        expect(user.factionsList, [Faction.gakki]);
      });
    });
  });
}
