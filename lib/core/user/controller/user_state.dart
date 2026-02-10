part of 'user_cubit.dart';

@freezed
sealed class UserState with _$UserState {
  const UserState._();
  const factory UserState.initial() = Initial;
  const factory UserState.loading() = Loading;
  const factory UserState.loaded(User user) = Loaded;
  const factory UserState.updating(User user) = Updating;
  const factory UserState.updateSuccess(User user, String message) = UpdateSuccess;
  const factory UserState.deleted() = Deleted;
  const factory UserState.error(String message) = ApiError;

  User? get userOrNull => maybeMap(
    loaded: (s) => s.user,
    updating: (s) => s.user,
    orElse: () => null,
  );
}
