import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/achievements/data/models/attributes_dto.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/achievements/domain/mock/generate_badges.dart';
import 'package:reforge/features/achievements/domain/mock/generate_ranks.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

abstract interface class AchievementsRepository {
  Future<Result<List<AttributesEntity>>> getUserAttributes();
  Faction? getUserFaction();
  Future<Result<List<BadgeEntity>>> getUserBadges();
  Future<Result<List<RankEntity>>> getUserRanks(Faction faction);
}

@Injectable(as: AchievementsRepository)
class AchievementsRepositoryImpl implements AchievementsRepository {
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
      final result = await _apiClient.getUserAttributes();

      final mappedList = result.data.map((attribute) => attribute.toDomain()).toList();
      return Result.success(mappedList);
    } on DioException catch (e) {
      // TODO (Masayoshi): remove that staff when endpoint is ready

      if (e.response?.statusCode == 404) {
        final mockedList = [
          const AttributesDto(id: 'kannuki', name: 'Kannuki', currentXp: 150, totalXp: 1000),
          const AttributesDto(id: 'kobo', name: 'Kobo', currentXp: 800, totalXp: 1000),
          const AttributesDto(id: 'kozuchi', name: 'Kozuchi', currentXp: 45, totalXp: 1000),
          const AttributesDto(id: 'sensho', name: 'Sensho', currentXp: 700, totalXp: 1000),
          const AttributesDto(id: 'kobokai', name: 'Kobokai', currentXp: 0, totalXp: 1000),
        ];

        final mappedList = mockedList.map((attribute) => attribute.toDomain()).toList();

        return Result.success(mappedList);
      }
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<BadgeEntity>>> getUserBadges() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      return Result.success(BadgesGenerator.generateBadges());
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
