import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/notifications/domain/enum/device_type.dart';
import 'package:reforge/features/notifications/domain/enum/notification_type.dart';

part 'notification_test_request.freezed.dart';
part 'notification_test_request.g.dart';

@freezed
sealed class NotificationTestRequest with _$NotificationTestRequest {
  const factory NotificationTestRequest({
    required NotificationType notificationType,
    required NotificationMetadata metadata,
  }) = _NotificationTestRequest;

  factory NotificationTestRequest.fromJson(Map<String, dynamic> json) => _$NotificationTestRequestFromJson(json);
}

@freezed
sealed class NotificationMetadata with _$NotificationMetadata {
  const factory NotificationMetadata({
    required String token,
    required DeviceType deviceType,
  }) = _NotificationMetadata;

  factory NotificationMetadata.fromJson(Map<String, dynamic> json) => _$NotificationMetadataFromJson(json);

  factory NotificationMetadata.current({required String token}) => NotificationMetadata(
    token: token,
    deviceType: Platform.isAndroid ? DeviceType.android : DeviceType.ios,
  );
}
