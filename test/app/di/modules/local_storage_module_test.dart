import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/di/modules/local_storage_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class TestLocalStorageModule extends LocalStorageModule {}

void main() {
  test('removes the legacy cached user without clearing unrelated preferences', () async {
    SharedPreferences.setMockInitialValues({
      'cached_user_profile': '{"id":71}',
      'unrelated_setting': true,
    });

    final preferences = await TestLocalStorageModule().sharedPreferences;

    expect(preferences.containsKey('cached_user_profile'), isFalse);
    expect(preferences.getBool('unrelated_setting'), isTrue);
  });
}
