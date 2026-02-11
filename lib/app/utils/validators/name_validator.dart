import 'package:reforge/generated/i18n/translations.g.dart';

class NameValidator {
  const NameValidator._();

  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.validation.nameRequired;
    }

    if (value.trim().length < 2) {
      return t.validation.nameMinLength;
    }

    if (value.trim().length > 100) {
      return t.validation.nameMaxLength;
    }

    // Проверка на только буквы, пробелы и дефисы
    final nameRegex = RegExp(r"^[a-zA-Zà-žÀ-Ž\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return t.validation.nameInvalidCharacters;
    }

    return null;
  }
}
