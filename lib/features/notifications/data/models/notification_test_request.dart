import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';

part 'notification_test_request.freezed.dart';
part 'notification_test_request.g.dart';

@freezed
sealed class NotificationTestRequest with _$NotificationTestRequest {
  const factory NotificationTestRequest({
    @JsonKey(name: 'notificationType') required NotificationType notificationType,
    @JsonKey(name: 'metadata') required NotificationMetadata metadata,
  }) = _NotificationTestRequest;

  factory NotificationTestRequest.fromJson(Map<String, dynamic> json) => _$NotificationTestRequestFromJson(json);
}

@freezed
sealed class NotificationMetadata with _$NotificationMetadata {
  const factory NotificationMetadata({
    @JsonKey(name: 'new_rank') required String newRank,
    @JsonKey(name: 'xp_bonus') required int xpBonus,
  }) = _NotificationMetadata;

  factory NotificationMetadata.fromJson(Map<String, dynamic> json) => _$NotificationMetadataFromJson(json);
}
