import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_email_req.freezed.dart';
part 'password_reset_email_req.g.dart';

@freezed
sealed class PasswordResetEmailRequest with _$PasswordResetEmailRequest {
  const factory PasswordResetEmailRequest({
    required String email,
  }) = _PasswordResetEmailRequest;

  factory PasswordResetEmailRequest.fromJson(Map<String, dynamic> json) => _$PasswordResetEmailRequestFromJson(json);
}
