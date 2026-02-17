import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/notifications/domain/enum/device_type.dart';

part 'register_tokens_request.freezed.dart';
part 'register_tokens_request.g.dart';

@freezed
sealed class RegisterFcmTokensRequestDto with _$RegisterFcmTokensRequestDto {
  const factory RegisterFcmTokensRequestDto({
    required String token,
    required DeviceType deviceType,
  }) = _RegisterFcmTokensRequestDto;

  factory RegisterFcmTokensRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterFcmTokensRequestDtoFromJson(json);
}
