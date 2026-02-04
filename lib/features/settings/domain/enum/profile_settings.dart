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
}
