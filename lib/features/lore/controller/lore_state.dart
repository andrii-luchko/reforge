part of 'lore_cubit.dart';

@freezed
sealed class LoreState with _$LoreState {
  const LoreState._();

  const factory LoreState({
    @Default([]) List<PlatesEntity> items,
    @Default(false) bool isLoading,
    String? error,
  }) = _LoreState;
}
