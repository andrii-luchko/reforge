import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';

part 'achievement_badge_dto.freezed.dart';
part 'achievement_badge_dto.g.dart';

@freezed
sealed class AchievementBadgeDto with _$AchievementBadgeDto {
  const AchievementBadgeDto._();

  const factory AchievementBadgeDto({
    required int id,
    required String name,
    required String key,
    String? exerciseMetric,
    String? iconUrlKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isCompleted,
    UserProgressDto? userProgress,
    String? iconUrl,
  }) = _AchievementBadgeDto;

  factory AchievementBadgeDto.fromJson(Map<String, dynamic> json) => _$AchievementBadgeDtoFromJson(json);

  BadgeEntity toDomain() {
    return BadgeEntity(imageUrl: iconUrl ?? '', title: name, isLocked: !isCompleted);
  }
}

@freezed
sealed class UserProgressDto with _$UserProgressDto {
  const factory UserProgressDto({
    required int id,
    required int tier,
    required String key,
  }) = _UserProgressDto;

  factory UserProgressDto.fromJson(Map<String, dynamic> json) => _$UserProgressDtoFromJson(json);
}
