import 'package:reforge/features/guides/domain/entities/guide_id.dart';

abstract interface class GuideProgressRepository {
  Future<bool> isCompleted({
    required int userId,
    required GuideId guideId,
  });

  Future<void> markCompleted({
    required int userId,
    required GuideId guideId,
  });
}
