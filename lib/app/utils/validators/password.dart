import 'package:reforge/generated/i18n/translations.g.dart';

String? validatePassword(String? value) {
  final password = value?.trim();

  if (password == null || password.isEmpty) {
    return t.validation.password_required;
  }
  if (password.length < 8) {
    return t.validation.password_too_short;
  }
  return null;
}

String? validateConfirmPassword(String? confirmPassword, String? password) {
  final passwordValue = password?.trim();
  final confirmPasswordValue = confirmPassword?.trim();

  if (confirmPasswordValue == null || confirmPasswordValue.isEmpty) {
    return t.validation.password_required;
  }

  if (confirmPasswordValue != passwordValue) {
    return t.validation.passwords_not_match;
  }

  return null;
}
