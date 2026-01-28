part of 'user_cubit.dart';

@freezed
sealed class UserState with _$UserState {
  const factory UserState.initial() = Initial;
  const factory UserState.loading() = Loading;
  const factory UserState.loaded(User user) = Loaded;
  const factory UserState.deleted() = Deleted;
  const factory UserState.error(String message) = ApiError;
}
