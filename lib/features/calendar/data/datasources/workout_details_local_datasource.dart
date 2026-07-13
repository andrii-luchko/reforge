import 'package:injectable/injectable.dart';

import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';

abstract interface class WorkoutDetailsLocalDataSource {
  TrainingDetailsEntity? get(int sessionId);
  void put(int sessionId, TrainingDetailsEntity? entity);
  void remove(int sessionId);
}

@LazySingleton(as: WorkoutDetailsLocalDataSource)
class WorkoutDetailsLocalDataSourceImpl implements WorkoutDetailsLocalDataSource {
  final _cache = <int, TrainingDetailsEntity?>{};

  @override
  TrainingDetailsEntity? get(int sessionId) => _cache[sessionId];

  @override
  void put(int sessionId, TrainingDetailsEntity? entity) {
    _cache[sessionId] = entity;
  }

  @override
  void remove(int sessionId) {
    _cache.remove(sessionId);
  }
}
