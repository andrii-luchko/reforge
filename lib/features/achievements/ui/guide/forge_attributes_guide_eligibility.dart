import 'package:reforge/features/achievements/controllers/achievements_cubit.dart';

bool canStartForgeAttributesGuide({
  required AchievementsState state,
  required int? userId,
}) {
  return userId != null && !state.isLoading && state.attributes.isNotEmpty;
}
