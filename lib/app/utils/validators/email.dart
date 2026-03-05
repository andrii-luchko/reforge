import 'package:reforge/generated/i18n/strings.g.dart';

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return t.validation.email_required;
  }

  if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
    return t.validation.email_invalid;
  }

  return null;
}
