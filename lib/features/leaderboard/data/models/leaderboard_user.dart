import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_entity.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

part 'leaderboard_user.freezed.dart';
part 'leaderboard_user.g.dart';

@freezed
sealed class LeaderboardUser with _$LeaderboardUser {
  const factory LeaderboardUser({
    required int id,
    required String role,
    required int rank,
    required Progress progress,
    String? email,
    @JsonKey(name: 'username') String? name,
    String? avatarUrl,
  }) = _LeaderboardUser;

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) => _$LeaderboardUserFromJson(json);
}

@freezed
sealed class CurrentUserRank with _$CurrentUserRank {
  const factory CurrentUserRank({
    required int userId,
    required int rank,
    required Progress progress,
    @JsonKey(name: 'username') String? name,
    String? avatarUrl,
  }) = _CurrentUserRank;

  factory CurrentUserRank.fromJson(Map<String, dynamic> json) => _$CurrentUserRankFromJson(json);
}

@freezed
sealed class Progress with _$Progress {
  const factory Progress({
    required int level,
    required double xpToNextLevel,
    required double totalXp,
    required String rank,
  }) = _Progress;

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);
}

extension LeaderboardUserX on LeaderboardUser {
  LeaderboardUserEntity toDomain() {
    final username = name ?? '${t.home.header.default_username} #${id.toString().padLeft(4, '0')}';

    return LeaderboardUserEntity(
      rank: rank,

      username: username,
      avatarUrl: avatarUrl,
      xp: progress.totalXp.toInt(),
    );
  }
}

extension CurrentUserRankX on CurrentUserRank {
  LeaderboardUserEntity toDomain() {
    final username = name ?? '';

    //TODO(Masayoshl): as soon as backend fix current user rank change it here

    final realRank = (rank - 1).clamp(1, rank);

    return LeaderboardUserEntity(
      rank: realRank,
      username: username,
      avatarUrl: avatarUrl,
      xp: progress.totalXp.toInt(),
    );
  }
}
