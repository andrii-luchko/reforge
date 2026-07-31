import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';

part 'badge_dto.freezed.dart';
part 'badge_dto.g.dart';

@freezed
sealed class BadgeDto with _$BadgeDto {
  const BadgeDto._();
  const factory BadgeDto({
    required int id,
    required int userId,
    required int milestoneId,
    required int tier,
    required String key,
    required DateTime createdAt,
    required DateTime updatedAt,
    required MilestoneDto milestone,
    String? iconUrl,
  }) = _BadgeDto;

  factory BadgeDto.fromJson(Map<String, dynamic> json) => _$BadgeDtoFromJson(json);

  BadgeEntity toDomain() {
    return BadgeEntity(
      id: milestone.id,
      imageUrl: iconUrl ?? '',
      title: milestone.name,
      isLocked: false,
      key: milestone.key,
      exerciseMetric: milestone.exerciseMetric,
      tier: tier,
    );
  }
}

@freezed
sealed class MilestoneDto with _$MilestoneDto {
  const factory MilestoneDto({
    required int id,
    required String name,
    required String key,
    required String exerciseMetric,
    String? iconUrlKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MilestoneDto;

  factory MilestoneDto.fromJson(Map<String, dynamic> json) => _$MilestoneDtoFromJson(json);
}
