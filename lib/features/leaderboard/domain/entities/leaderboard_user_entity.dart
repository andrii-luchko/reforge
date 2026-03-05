// ignore_for_file: always_put_required_named_parameters_first

import 'package:freezed_annotation/freezed_annotation.dart';

part 'leaderboard_user_entity.freezed.dart';

@freezed
sealed class LeaderboardUserEntity with _$LeaderboardUserEntity {
  const LeaderboardUserEntity._();

  const factory LeaderboardUserEntity({
    required int rank,
    required String username,
    String? avatarUrl,
    required int xp,
  }) = _LeaderboardUserEntity;
}
