import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

import '../mocks/mock_leaderboard_repository.dart';

ImmortalForgeEntity createTestImmortalForgeEntity({
  int userId = 1,
  String email = 'test@test.com',
  int score = 100,
  int rank = 1,
  String title = 'Daizōshō',
}) {
  return ImmortalForgeEntity(
    userId: userId,
    email: email,
    score: score,
    rank: rank,
    title: title,
  );
}

void main() {
  late MockLeaderboardRepository mockRepository;

  setUp(() {
    mockRepository = MockLeaderboardRepository();
  });

  group('ImmortalForgesCubit', () {
    test('init Success emits selectedFaction and forgeData', () async {
      final leaders = [createTestImmortalForgeEntity()];
      when(() => mockRepository.getUserFaction()).thenReturn(Faction.gakki);
      when(() => mockRepository.getImmortalForgesForFaction(Faction.gakki))
          .thenAnswer((_) async => Result.success(leaders));

      final cubit = ImmortalForgesCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.selectedFaction, Faction.gakki);
      expect(cubit.state.forgeData[Faction.gakki], leaders);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.error, isNull);
    });

    test('init Error emits error and isLoading false', () async {
      when(() => mockRepository.getUserFaction()).thenReturn(null);
      when(() => mockRepository.getImmortalForgesForFaction(Faction.gakki))
          .thenAnswer((_) async => Result.error(Exception('Network error')));

      final cubit = ImmortalForgesCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isLoading, false);
      expect(cubit.state.error, isNotNull);
    });

    test('changeFaction when cached does not call repository', () async {
      final leaders = [createTestImmortalForgeEntity()];
      when(() => mockRepository.getUserFaction()).thenReturn(Faction.gakki);
      when(() => mockRepository.getImmortalForgesForFaction(Faction.gakki))
          .thenAnswer((_) async => Result.success(leaders));

      final cubit = ImmortalForgesCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.changeFaction(Faction.gakki);

      verify(() => mockRepository.getImmortalForgesForFaction(Faction.gakki)).called(1);
    });

    test('changeFaction when not cached calls repository', () async {
      final gakkiLeaders = [createTestImmortalForgeEntity()];
      final gyohyoLeaders = [createTestImmortalForgeEntity(userId: 2)];
      when(() => mockRepository.getUserFaction()).thenReturn(Faction.gakki);
      when(() => mockRepository.getImmortalForgesForFaction(Faction.gakki))
          .thenAnswer((_) async => Result.success(gakkiLeaders));
      when(() => mockRepository.getImmortalForgesForFaction(Faction.gyohyo))
          .thenAnswer((_) async => Result.success(gyohyoLeaders));

      final cubit = ImmortalForgesCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.changeFaction(Faction.gyohyo);

      expect(cubit.state.forgeData[Faction.gyohyo], gyohyoLeaders);
      verify(() => mockRepository.getImmortalForgesForFaction(Faction.gyohyo)).called(1);
    });

    test('refresh calls repository for selectedFaction', () async {
      final leaders = [createTestImmortalForgeEntity()];
      when(() => mockRepository.getUserFaction()).thenReturn(Faction.gakki);
      when(() => mockRepository.getImmortalForgesForFaction(Faction.gakki))
          .thenAnswer((_) async => Result.success(leaders));

      final cubit = ImmortalForgesCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.refresh();

      verify(() => mockRepository.getImmortalForgesForFaction(Faction.gakki)).called(2);
    });
  });

  group('ImmortalForgesState currentList', () {
    test('returns forgeData for selectedFaction', () {
      final leaders = [createTestImmortalForgeEntity()];
      final state = ImmortalForgesState(
        forgeData: {Faction.gakki: leaders},
      );
      expect(state.currentList, leaders);
    });

    test('returns empty list when faction not in forgeData', () {
      const state = ImmortalForgesState(
        
      );
      expect(state.currentList, isEmpty);
    });
  });
}
