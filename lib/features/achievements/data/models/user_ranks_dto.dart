import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/achievements/data/enum/rank_status.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'user_ranks_dto.freezed.dart';
part 'user_ranks_dto.g.dart';

@freezed
sealed class UserRankData with _$UserRankData {
  const factory UserRankData({
    required int id,
    required String username,
    required RankInfo currentRank,
    required List<ProgressionStep> progression,
  }) = _UserRankData;

  factory UserRankData.fromJson(Map<String, dynamic> json) => _$UserRankDataFromJson(json);
}

@freezed
sealed class RankInfo with _$RankInfo {
  const factory RankInfo({
    required int tier,
    required String rank,
    required String japanRank,
  }) = _RankInfo;

  factory RankInfo.fromJson(Map<String, dynamic> json) => _$RankInfoFromJson(json);
}

@freezed
sealed class ProgressionStep with _$ProgressionStep {
  const ProgressionStep._();

  const factory ProgressionStep({
    required int tier,
    required String rank,
    required String japanRank,
    required RankStatus status,
  }) = _ProgressionStep;

  factory ProgressionStep.fromJson(Map<String, dynamic> json) => _$ProgressionStepFromJson(json);

  RankEntity toDomain(Faction faction) {
    return RankEntity(
      imageAsset: faction.rankCardAsset(),
      japanRankName: japanRank,
      rankName: rank,
      faction: faction,
      lvl: null,
      xp: null,
      maxXp: null,
    );
  }
}
