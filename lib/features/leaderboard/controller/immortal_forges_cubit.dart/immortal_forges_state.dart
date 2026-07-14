part of 'immortal_forges_cubit.dart';

@freezed
sealed class ImmortalForgesState with _$ImmortalForgesState {
  const ImmortalForgesState._();

  const factory ImmortalForgesState({
    @Default(Faction.gakki) Faction selectedFaction,
    @Default({}) Map<Faction, List<ImmortalForgeEntity>> forgeData,
    @Default(false) bool isLoading,
    String? error,
  }) = _ImmortalForgesState;

  List<ImmortalForgeEntity> get currentList => forgeData[selectedFaction] ?? [];

  bool get areAllFactionsLoaded => !isLoading && error == null && Faction.values.every(forgeData.containsKey);
}
