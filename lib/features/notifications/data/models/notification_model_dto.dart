import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/notifications/domain/entities/notification_entity.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

part 'notification_model_dto.freezed.dart';
part 'notification_model_dto.g.dart';

@freezed
sealed class NotificationModelDto with _$NotificationModelDto {
  const NotificationModelDto._();

  const factory NotificationModelDto({
    required int id,
    required int userId,
    required DateTime createdAt,
    @JsonKey(name: 'type') required NotificationType type,
    required Map<String, dynamic> metadata,
    required bool isRead,
  }) = _NotificationModelDto;

  factory NotificationModelDto.fromJson(Map<String, dynamic> json) => _$NotificationModelDtoFromJson(json);

  NotificationEntity toEntity() {
    return NotificationEntity(
      title: type.title(t),
      subtitle: type.description(t),
      date: createdAt,
      id: id,
      type: type,
    );
  }
}
