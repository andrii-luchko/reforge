import 'package:reforge/generated/i18n/translations.g.dart';

String? validateDateOfBirth(DateTime? value, {DateTime? currentTime, int minAge = 10}) {
  if (value == null) {
    return t.validation.date_of_birth_required;
  }

  final now = currentTime ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dob = DateTime(value.year, value.month, value.day);

  if (dob.isAfter(today)) {
    return t.validation.date_of_birth_future;
  }

  var age = today.year - dob.year;
  if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
    age--;
  }

  if (age > 100) {
    return t.validation.date_of_birth_invalid;
  }

  if (age < minAge) {
    return t.validation.date_of_birth_too_young(mimAge: minAge);
  }

  return null;
}
