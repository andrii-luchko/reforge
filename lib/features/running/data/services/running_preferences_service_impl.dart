import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reforge/features/running/domain/services/running_preferences_service.dart';

@LazySingleton(as: RunningPreferencesService)
class RunningPreferencesServiceImpl implements RunningPreferencesService {
  RunningPreferencesServiceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _audioHintKey = 'has_seen_audio_hint';

  @override
  bool get hasSeenAudioHint => _prefs.getBool(_audioHintKey) ?? false;

  @override
  Future<void> markAudioHintSeen() async {
    await _prefs.setBool(_audioHintKey, true);
  }
}
