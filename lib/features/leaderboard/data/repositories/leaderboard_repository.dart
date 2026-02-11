import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/leaderboard/data/response/immortal_forges_response.dart';
import 'package:reforge/features/leaderboard/data/response/leaderboard_users_response.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

// ignore: prefer_match_file_name
abstract interface class LeaderboardRepositoryI {
  Future<Result<MappedLeaderboardData>> getGlobalUserListPaginated({required int page, int limit = 20});

  Future<Result<List<ImmortalForgeEntity>>> getImmortalForgesForFaction(Faction faction);

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
  Future<Result<List<ImmortalForgeEntity>>> getImmortalForgesForFaction(Faction faction) async {
    try {
      final response = await _apiClient.getImmortalForges(faction.name);
      logger.d(response.data);
      final parsed = response.toDomain();
      return Result.success(parsed);
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

      final local = results.first.data;
      final global = results[1].data;

      final globalScores = {for (final dto in global) dto.factionId: dto.totalWins};

      final finalModels = <LeaderboardFactionModel>[];

      for (final localDto in local) {
        final faction = Faction.fromId(localDto.factionId);

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
      onboarded: (u) => Faction.fromId(u.factionId),
    );
  }
}
