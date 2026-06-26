import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/core/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class LocalStorageModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @preResolve
  Future<FlutterSecureStorage> get secureStorage async {
    return const FlutterSecureStorage();
  }

  @lazySingleton
  WorkoutDatabase get workoutDatabase => WorkoutDatabase(driftDatabase(name: 'workout_db'));
}
