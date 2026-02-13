part of 'lore_cubit.dart';

@freezed
sealed class LoreState with _$LoreState {
  const LoreState._();

  const factory LoreState({
    @Default([]) List<PlatesEntity> items,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(0) int totalCount,
    String? error,
    int? loadingDetailId,
  }) = _LoreState;
}
