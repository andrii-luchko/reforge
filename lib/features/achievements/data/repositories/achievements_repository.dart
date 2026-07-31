import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/achievements/data/enum/rank_status.dart';
import 'package:reforge/features/achievements/data/mock/achievement_badges_mock.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

abstract interface class AchievementsRepository {
  Future<Result<List<AttributesEntity>>> getUserAttributes();
  Future<Result<List<BadgeEntity>>> getUserBadges();
  Future<Result<List<RankEntity>>> getUserRanks(Faction faction);
}

@Injectable(as: AchievementsRepository)
class AchievementsRepositoryImpl with RepositoryErrorHandler implements AchievementsRepository {
  const AchievementsRepositoryImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Result<List<AttributesEntity>>> getUserAttributes() async {
    try {
      final result = await makeRequest(
        () async {
          final result = await _apiClient.getUserAttributes();

          final mappedList = result.data
              .map((attribute) => attribute.toDomain())
              .sorted((a, b) => a.attribute.index.compareTo(b.attribute.index))
              .toList();
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
          final badges = useMockWorkoutMilestones ? mockAchievementBadges : (await _apiClient.getUserBadges()).data;

          final mappedList = badges.map((badge) => badge.toDomain()).toList();
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
      final result = await makeRequest(
        () async {
          final result = await _apiClient.getUserRanks(faction.name);

          final mappedList = result.data.progression
              .where((v) => v.status != RankStatus.locked)
              .map((e) => e.toDomain(faction));
          return mappedList.toList();
        },
        label: 'getUserBadges',
      );

      return Result.success(result);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
