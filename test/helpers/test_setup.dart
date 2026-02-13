import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/generated/i18n/strings.g.dart';

void initTestTranslations() {
  TestWidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.setLocaleSync(AppLocale.en);
}
