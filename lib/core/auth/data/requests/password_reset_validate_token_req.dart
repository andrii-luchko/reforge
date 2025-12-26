import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_validate_token_req.freezed.dart';
part 'password_reset_validate_token_req.g.dart';

@freezed
sealed class PasswordResetValidateTokenRequest with _$PasswordResetValidateTokenRequest {
  const factory PasswordResetValidateTokenRequest({
    required String token,
  }) = _PasswordResetValidateTokenRequest;

  factory PasswordResetValidateTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetValidateTokenRequestFromJson(json);
}
