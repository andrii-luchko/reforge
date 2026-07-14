// ignore_for_file: unnecessary_raw_strings, prefer_single_quotes

import 'package:reforge/generated/i18n/translations.g.dart';

final _emailRegex = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+"
  r"@[A-Za-z0-9]"
  r"(?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
  r"(?:\.[A-Za-z0-9]"
  r"(?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
);

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return t.validation.email_required;
  }

  if (!_emailRegex.hasMatch(value)) {
    return t.validation.email_invalid;
  }

  return null;
}
