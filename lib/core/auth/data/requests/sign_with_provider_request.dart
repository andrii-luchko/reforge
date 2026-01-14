import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/core/auth/data/enums/auth_providers.dart';

part 'sign_with_provider_request.freezed.dart';
part 'sign_with_provider_request.g.dart';

@freezed
sealed class SignWithProviderRequest with _$SignWithProviderRequest {
  const factory SignWithProviderRequest({
    required String token,
    required AuthProviders provider,
    String? firstName,
    String? lastName,
  }) = _SignWithProviderRequest;

  factory SignWithProviderRequest.fromJson(Map<String, dynamic> json) => _$SignWithProviderRequestFromJson(json);
}
