import 'package:reforge/generated/i18n/strings.g.dart';

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return t.validation.email_required;
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return t.validation.email_invalid;
  }

  return null;
}
