part of 'notification_feed_cubit.dart';

@freezed
sealed class NotificationFeedState with _$NotificationFeedState {
  const factory NotificationFeedState.initial() = _Initial;

  const factory NotificationFeedState.loading() = _Loading;

  const factory NotificationFeedState.loaded({
    required List<NotificationEntity> notifications,
    required bool hasMore,
    @Default(false) bool isLoadingMore,
    String? error,
  }) = _Loaded;

  const factory NotificationFeedState.error(String message) = _Error;
}
