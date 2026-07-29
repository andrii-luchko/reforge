import 'package:injectable/injectable.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/domain/repositories/guide_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: GuideProgressRepository)
class SharedPreferencesGuideProgressRepository implements GuideProgressRepository {
  const SharedPreferencesGuideProgressRepository(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    return _preferences.getBool(_key(userId, guideId)) ?? false;
  }

  @override
  Future<void> markCompleted({
    required int userId,
    required GuideId guideId,
  }) async {
    final saved = await _preferences.setBool(_key(userId, guideId), true);
    if (!saved) throw StateError('Could not persist guide completion');
  }

  String _key(int userId, GuideId guideId) => 'guides.$userId.${guideId.storageKey}.completed';
}
