import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_confirm_req.freezed.dart';
part 'password_reset_confirm_req.g.dart';

@freezed
sealed class PasswordResetConfirmRequest with _$PasswordResetConfirmRequest {
  const factory PasswordResetConfirmRequest({
    required String token,
    @JsonKey(name: 'password') required String newPassword,
  }) = _PasswordResetConfirmRequest;

  factory PasswordResetConfirmRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetConfirmRequestFromJson(json);
}
