part of 'achievements_cubit.dart';

@freezed
sealed class AchievementsState with _$AchievementsState {
  const AchievementsState._();

  const factory AchievementsState({
    @Default([]) List<AttributesEntity> attributes,

    @Default([]) List<BadgeEntity> badges,

    @Default(Faction.gakki) Faction selectedFaction,
    @Default([]) List<RankEntity> ranks,
    @Default(false) bool isLoading,
    String? error,
  }) = _AchievementsState;

  int get unLockedCount => badges.where((b) => !b.isLocked).length;
}
