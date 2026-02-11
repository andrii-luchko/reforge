import 'package:reforge/app/utils/helpers/date_locale_helper.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

enum ProfileSettings {
  image,
  name,
  email,
  dateOfBirth,
  heightAndWeight,
}

extension ProfileSettingsX on ProfileSettings {
  String get icon {
    return switch (this) {
      ProfileSettings.image => Assets.images.icons.gallery,
      ProfileSettings.name => Assets.images.icons.user,
      ProfileSettings.email => Assets.images.icons.sms,
      ProfileSettings.dateOfBirth => Assets.images.icons.calendar,
      ProfileSettings.heightAndWeight => Assets.images.icons.weight,
    };
  }

  String title(Translations t) {
    return switch (this) {
      ProfileSettings.image => 'Upload image',
      ProfileSettings.name => 'Name',
      ProfileSettings.email => 'Email',
      ProfileSettings.dateOfBirth => 'Date of birth',
      ProfileSettings.heightAndWeight => 'Weight',
    };
  }

  String? getDisplayValue(OnboardedUser user, Translations t) {
    return switch (this) {
      ProfileSettings.image => user.avatarUrl,
      ProfileSettings.name => user.userName ?? 'Set your name',
      ProfileSettings.email => user.email,
      ProfileSettings.dateOfBirth => formatDate(user.birthDate),
      ProfileSettings.heightAndWeight =>
        user.bodyWeight == null ? null : '${user.displayedWeight} ${user.measurementSystem.weightSymbol(t)}',
    };
  }

  String formatDate(DateTime date) {
    final locale = LocaleSettings.currentLocale.languageTag;
    final separator = DateLocaleHelper.getSeparator(locale);
    final isDayFirst = DateLocaleHelper.isDayFirst(locale);
    return DateLocaleHelper.formatDate(date, isDayFirst: isDayFirst, separator: separator);
  }
}
