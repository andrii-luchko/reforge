part of 'home_cubit.dart';

@freezed
sealed class HomeState with _$HomeState {
  const HomeState._();
  const factory HomeState({
    OnboardedUser? user,
    RankEntity? rank,
    @Default({}) Map<StatsPeriod, UserStats> statsMap,
    @Default(StatsPeriod.lastWeek) StatsPeriod period,
    @Default(false) bool isLoading,
    @Default(false) bool isStatsLoading,
    String? error,
  }) = _HomeState;

  UserStats? get currentStats => statsMap[period];
}
