part of 'settings_cubit.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState({
    String? emailError,
    String? apiError,
  }) = _SettingsState;

  const SettingsState._();
}
