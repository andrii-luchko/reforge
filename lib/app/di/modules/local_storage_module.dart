import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/core/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class LocalStorageModule {
  static const _legacyCachedUserProfileKey = 'cached_user_profile';

  @preResolve
  Future<SharedPreferences> get sharedPreferences async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyCachedUserProfileKey);
    return preferences;
  }

  @preResolve
  Future<FlutterSecureStorage> get secureStorage async {
    return const FlutterSecureStorage();
  }

  @lazySingleton
  WorkoutDatabase get workoutDatabase => WorkoutDatabase(
    driftDatabase(
      name: 'workout_db',
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
        setup: (db) {
          db
            ..execute('PRAGMA foreign_keys = ON;')
            ..execute('PRAGMA journal_mode=WAL;')
            ..execute('PRAGMA synchronous=NORMAL;');
        },
      ),
    ),
  );
}
