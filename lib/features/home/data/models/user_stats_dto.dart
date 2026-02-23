import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/home/data/models/badge_dto.dart';
import 'package:reforge/features/home/domain/user_stats.dart';

part 'user_stats_dto.freezed.dart';
part 'user_stats_dto.g.dart';

@freezed
sealed class UserStatsDataDto with _$UserStatsDataDto {
  const UserStatsDataDto._();

  const factory UserStatsDataDto({
    required UserXpStatsDto userXpStats,
    required int totalWorkoutsDuration,
    required int workoutsCount,
    required int activeDays,
    required int totalDays,
    BadgeDto? lastEarnedBadge,
  }) = _UserStatsDataDto;

  factory UserStatsDataDto.fromJson(Map<String, dynamic> json) => _$UserStatsDataDtoFromJson(json);

  UserStats toDomain() {
    return UserStats(
      level: userXpStats.level,
      xpToNextLevel: userXpStats.xpToNextLevel,
      totalXp: userXpStats.totalXp,
      totalDays: totalDays,
      activeDays: activeDays,
      totalWorkoutsDuration: totalWorkoutsDuration,
      workoutsCount: workoutsCount,
      badgeName: lastEarnedBadge?.milestone.name,
      badgeImageUrl: lastEarnedBadge?.iconUrl,
    );
  }
}

@freezed
sealed class UserXpStatsDto with _$UserXpStatsDto {
  const factory UserXpStatsDto({
    required int level,
    required int xpToNextLevel,
    required int totalXp,
  }) = _UserXpStatsDto;

  factory UserXpStatsDto.fromJson(Map<String, dynamic> json) => _$UserXpStatsDtoFromJson(json);
}
