import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/leaderboard/data/response/leaderboard_users_response.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

abstract interface class LeaderboardRepositoryI {
  Future<Result<MappedLeaderboardData>> getGlobalUserListPaginated({required int page, int limit = 20});

  Faction? getUserFaction();

  Future<Result<List<LeaderboardFactionModel>>> getFactionsLeaderboard();
}

@Injectable(as: LeaderboardRepositoryI)
class LeaderboardRepositoryImpl implements LeaderboardRepositoryI {
  const LeaderboardRepositoryImpl(this._apiClient, this._userSessionService);

  final UserSessionService _userSessionService;
  final ApiClient _apiClient;

  @override
  Future<Result<MappedLeaderboardData>> getGlobalUserListPaginated({required int page, int limit = 20}) async {
    try {
      final response = await _apiClient.getGlobalUserList(page, limit);
      return Result.success(response.toDomain());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<LeaderboardFactionModel>>> getFactionsLeaderboard() async {
    try {
      final results = await Future.wait([
        _apiClient.getLocalFactionsLeaderboard(),
        _apiClient.getGlobalFactionsLeaderboard(),
      ]);

      final local = results[0].data;
      final global = results[1].data;

      final globalScores = {for (final dto in global) dto.factionId: dto.totalWins};

      final finalModels = <LeaderboardFactionModel>[];

      for (final localDto in local) {
        final faction = Faction.getById(localDto.factionId);

        if (faction == null) continue;

        finalModels.add(
          LeaderboardFactionModel(
            faction: faction,
            activeUsers: 0,
            xp: 0,
            localScore: localDto.totalWins,
            globalScore: globalScores[localDto.factionId] ?? 0,
          ),
        );
      }

      return Result.success(finalModels);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Faction? getUserFaction() {
    return _userSessionService.currentUser?.map(
      newUser: (_) => null,
      onboarded: (u) => Faction.getById(u.factionId),
    );
  }
}
