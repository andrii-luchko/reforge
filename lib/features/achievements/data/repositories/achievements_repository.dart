import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/achievements/domain/mock/generate_ranks.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

abstract interface class AchievementsRepository {
  Future<Result<List<AttributesEntity>>> getUserAttributes();
  Faction? getUserFaction();
  Future<Result<List<BadgeEntity>>> getUserBadges();
  Future<Result<List<RankEntity>>> getUserRanks(Faction faction);
}

@Injectable(as: AchievementsRepository)
class AchievementsRepositoryImpl with RepositoryErrorHandler implements AchievementsRepository {
  const AchievementsRepositoryImpl(this._apiClient, this._userSessionService);
  final UserSessionService _userSessionService;
  final ApiClient _apiClient;

  @override
  Faction? getUserFaction() {
    return _userSessionService.currentUser?.map(
      newUser: (_) => null,
      onboarded: (u) => Faction.fromId(u.factionId),
    );
  }

  @override
  Future<Result<List<AttributesEntity>>> getUserAttributes() async {
    try {
      final result = await makeRequest(
        () async {
          final result = await _apiClient.getUserAttributes();

          final mappedList = result.data.map((attribute) => attribute.toDomain()).toList();
          return mappedList;
        },
        label: 'getUserAttributes',
      );
      return Result.success(result);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<BadgeEntity>>> getUserBadges() async {
    try {
      final result = await makeRequest(
        () async {
          final result = await _apiClient.getUserBadges();

          final mappedList = result.data.map((badge) => badge.toDomain()).toList();
          return mappedList;
        },
        label: 'getUserBadges',
      );

      return Result.success(result);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<RankEntity>>> getUserRanks(Faction faction) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return Result.success(RanksGenerator.generateRanks(faction));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
