import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/leaderboard/controller/users_leaderboard_cubit.dart/users_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_model.dart';

import '../mocks/mock_leaderboard_repository.dart';

({LeaderboardUserModel currentUser, List<LeaderboardUserModel> usersList, int totalPages})
    createTestMappedLeaderboardData({
  List<LeaderboardUserModel>? usersList,
  LeaderboardUserModel? currentUser,
  int totalPages = 1,
}) {
  final defaultUser = LeaderboardUserModel(
    rank: 1,
    username: 'TestUser',
    avatarUrl: null,
    xp: 1000,
  );
  return (
    currentUser: currentUser ?? defaultUser,
    usersList: usersList ?? [defaultUser],
    totalPages: totalPages,
  );
}

void main() {
  late MockLeaderboardRepository mockRepository;

  setUp(() {
    mockRepository = MockLeaderboardRepository();
  });

  group('UsersLeaderboardCubit', () {
    test('loadUsers Success emits state with users and hasReachedMax', () async {
      final data = createTestMappedLeaderboardData(
        usersList: [
          LeaderboardUserModel(rank: 1, username: 'User1', avatarUrl: null, xp: 500),
        ],
        currentUser: LeaderboardUserModel(rank: 1, username: 'User1', avatarUrl: null, xp: 500),
        totalPages: 1,
      );
      when(() => mockRepository.getGlobalUserListPaginated(page: 1))
          .thenAnswer((_) async => Result.success(data));

      final cubit = UsersLeaderboardCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.currentUsersList, data.usersList);
      expect(cubit.state.currentUser, data.currentUser);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.hasReachedMax, true);
      expect(cubit.state.error, isNull);
    });

    test('loadUsers Error emits error and isLoading false', () async {
      when(() => mockRepository.getGlobalUserListPaginated(page: 1))
          .thenAnswer((_) async => Result.error(Exception('Network error')));

      final cubit = UsersLeaderboardCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isLoading, false);
      expect(cubit.state.error, isNotNull);
    });

    test('loadNextPage Success appends users and updates page', () async {
      final page1Data = createTestMappedLeaderboardData(
        usersList: [LeaderboardUserModel(rank: 1, username: 'User1', avatarUrl: null, xp: 500)],
        totalPages: 2,
      );
      final page2Data = createTestMappedLeaderboardData(
        usersList: [LeaderboardUserModel(rank: 2, username: 'User2', avatarUrl: null, xp: 400)],
        totalPages: 2,
      );
      when(() => mockRepository.getGlobalUserListPaginated(page: 1))
          .thenAnswer((_) async => Result.success(page1Data));
      when(() => mockRepository.getGlobalUserListPaginated(page: 2))
          .thenAnswer((_) async => Result.success(page2Data));

      final cubit = UsersLeaderboardCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.loadNextPage();

      expect(cubit.state.currentUsersList.length, 2);
      expect(cubit.state.currentPage, 2);
      expect(cubit.state.hasReachedMax, true);
      expect(cubit.state.isPaginationLoading, false);
    });

    test('loadNextPage Error emits paginationError', () async {
      final page1Data = createTestMappedLeaderboardData(totalPages: 2);
      when(() => mockRepository.getGlobalUserListPaginated(page: 1))
          .thenAnswer((_) async => Result.success(page1Data));
      when(() => mockRepository.getGlobalUserListPaginated(page: 2))
          .thenAnswer((_) async => Result.error(Exception('Pagination error')));

      final cubit = UsersLeaderboardCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.loadNextPage();

      expect(cubit.state.paginationError, isNotNull);
      expect(cubit.state.isPaginationLoading, false);
    });

    test('loadNextPage when hasReachedMax does not call repository', () async {
      final data = createTestMappedLeaderboardData(totalPages: 1);
      when(() => mockRepository.getGlobalUserListPaginated(page: 1))
          .thenAnswer((_) async => Result.success(data));

      final cubit = UsersLeaderboardCubit(mockRepository);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.loadNextPage();

      verifyNever(() => mockRepository.getGlobalUserListPaginated(page: 2));
    });
  });
}
