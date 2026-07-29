import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_entity.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

import '../../../core/user/mocks/mock_user_cubit.dart';
import '../mocks/mock_leaderboard_repository.dart';

({LeaderboardUserEntity currentUser, List<LeaderboardUserEntity> usersList, int totalPages})
createTestMappedLeaderboardData({
  List<LeaderboardUserEntity>? usersList,
  LeaderboardUserEntity? currentUser,
  int totalPages = 1,
}) {
  const defaultUser = LeaderboardUserEntity(
    rank: 1,
    username: 'TestUser',
    xp: 1000,
  );
  return (
    currentUser: currentUser ?? defaultUser,
    usersList: usersList ?? [defaultUser],
    totalPages: totalPages,
  );
}

OnboardedUser createTestOnboardedUser({String? username, String? email}) => OnboardedUser(
  id: 1,
  email: email,
  measurementSystem: MeasurementSystem.metric,
  factionId: 1,
  birthDate: DateTime(1990),
  workoutsPerWeek: 3,
  userName: username,
);

void main() {
  late MockLeaderboardRepository mockRepository;
  late MockUserCubit mockUserCubit;

  setUp(() {
    mockRepository = MockLeaderboardRepository();
    mockUserCubit = MockUserCubit();
    when(() => mockUserCubit.currentOnboardedUser).thenReturn(null);
    when(() => mockUserCubit.onboardedUserChanges).thenAnswer((_) => const Stream.empty());
  });

  group('UsersLeaderboardCubit', () {
    test('loadUsers Success emits state with users and hasReachedMax', () async {
      final data = createTestMappedLeaderboardData(
        usersList: [
          const LeaderboardUserEntity(rank: 1, username: 'User1', xp: 500),
        ],
        currentUser: const LeaderboardUserEntity(rank: 1, username: 'User1', xp: 500),
      );
      when(() => mockRepository.getGlobalUserListPaginated(page: 1)).thenAnswer((_) async => Result.success(data));

      final cubit = UsersLeaderboardCubit(mockRepository, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.currentUsersList, data.usersList);
      expect(cubit.state.currentUser, data.currentUser);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.hasReachedMax, true);
      expect(cubit.state.error, isNull);
    });

    test('loadUsers Error emits error and isLoading false', () async {
      when(
        () => mockRepository.getGlobalUserListPaginated(page: 1),
      ).thenAnswer((_) async => Result.error(Exception('Network error')));

      final cubit = UsersLeaderboardCubit(mockRepository, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isLoading, false);
      expect(cubit.state.error, isNotNull);
    });

    test('loadNextPage Success appends users and updates page', () async {
      final page1Data = createTestMappedLeaderboardData(
        usersList: [const LeaderboardUserEntity(rank: 1, username: 'User1', xp: 500)],
        totalPages: 2,
      );
      final page2Data = createTestMappedLeaderboardData(
        usersList: [const LeaderboardUserEntity(rank: 2, username: 'User2', xp: 400)],
        totalPages: 2,
      );
      when(() => mockRepository.getGlobalUserListPaginated(page: 1)).thenAnswer((_) async => Result.success(page1Data));
      when(() => mockRepository.getGlobalUserListPaginated(page: 2)).thenAnswer((_) async => Result.success(page2Data));

      final cubit = UsersLeaderboardCubit(mockRepository, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.loadNextPage();

      expect(cubit.state.currentUsersList.length, 2);
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.hasReachedMax, true);
      expect(cubit.state.isPaginationLoading, false);
    });

    test('loadNextPage Error emits paginationError', () async {
      final page1Data = createTestMappedLeaderboardData(totalPages: 2);
      when(() => mockRepository.getGlobalUserListPaginated(page: 1)).thenAnswer((_) async => Result.success(page1Data));
      when(
        () => mockRepository.getGlobalUserListPaginated(page: 2),
      ).thenAnswer((_) async => Result.error(Exception('Pagination error')));

      final cubit = UsersLeaderboardCubit(mockRepository, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.loadNextPage();

      expect(cubit.state.paginationError, isNotNull);
      expect(cubit.state.isPaginationLoading, false);
    });

    test('loadNextPage when hasReachedMax does not call repository', () async {
      final data = createTestMappedLeaderboardData();
      when(() => mockRepository.getGlobalUserListPaginated(page: 1)).thenAnswer((_) async => Result.success(data));

      final cubit = UsersLeaderboardCubit(mockRepository, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.loadNextPage();

      verifyNever(() => mockRepository.getGlobalUserListPaginated(page: 2));
    });

    test('reloads only for public user changes and clears on logout', () async {
      final changes = StreamController<OnboardedUser?>.broadcast();
      final initialUser = createTestOnboardedUser(username: 'Initial', email: 'old@example.com');
      final data = createTestMappedLeaderboardData();
      when(() => mockUserCubit.currentOnboardedUser).thenReturn(initialUser);
      when(() => mockUserCubit.onboardedUserChanges).thenAnswer((_) => changes.stream);
      when(() => mockRepository.getGlobalUserListPaginated(page: 1)).thenAnswer((_) async => Result.success(data));

      final cubit = UsersLeaderboardCubit(mockRepository, mockUserCubit);
      await Future<void>.delayed(Duration.zero);

      changes.add(initialUser.copyWith(email: 'new@example.com'));
      await Future<void>.delayed(Duration.zero);
      verify(() => mockRepository.getGlobalUserListPaginated(page: 1)).called(1);

      changes.add(initialUser.copyWith(userName: 'Updated'));
      await Future<void>.delayed(Duration.zero);
      verify(() => mockRepository.getGlobalUserListPaginated(page: 1)).called(1);

      changes.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, const UsersLeaderboardState());

      await cubit.close();
      await changes.close();
    });
  });
}
