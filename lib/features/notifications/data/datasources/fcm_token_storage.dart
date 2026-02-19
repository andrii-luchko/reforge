import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class FcmTokenStorage {
  Future<String?> getLastSavedToken();
  Future<void> saveToken(String token);
  Future<void> clear();
}

@Injectable(as: FcmTokenStorage)
class FcmTokenStorageImpl implements FcmTokenStorage {
  FcmTokenStorageImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'last_saved_fcm_token';

  @override
  Future<String?> getLastSavedToken() async {
    return _prefs.getString(_key);
  }

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(_key, token);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
