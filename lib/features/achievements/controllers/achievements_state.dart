part of 'achievements_cubit.dart';

@freezed
sealed class AchievementsState with _$AchievementsState {
  const AchievementsState._();

  const factory AchievementsState({
    @Default([]) List<AttributesEntity> attributes,
    @Default([]) List<BadgeEntity> badges,
    @Default(Faction.gakki) Faction selectedFaction,
    @Default({}) Map<Faction, List<RankEntity>> ranks,
    @Default(false) bool isLoading,
    String? error,
  }) = _AchievementsState;

  int get unLockedCount => badges.where((b) => !b.isLocked).length;

  List<RankEntity> get selectedRanks => ranks[selectedFaction] ?? [];
}
