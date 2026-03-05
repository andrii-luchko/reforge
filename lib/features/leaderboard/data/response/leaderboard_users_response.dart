import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/features/leaderboard/data/models/leaderboard_user.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_entity.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

part 'leaderboard_users_response.freezed.dart';
part 'leaderboard_users_response.g.dart';

typedef MappedLeaderboardData = ({
  LeaderboardUserEntity currentUser,
  List<LeaderboardUserEntity> usersList,
  int totalPages,
});

@freezed
sealed class LeaderboardResponse with _$LeaderboardResponse {
  const factory LeaderboardResponse({
    required List<LeaderboardUser> data,
    required MetaData meta,
    required String status,
    required CurrentUserRank currentUserPosition,
  }) = _LeaderboardResponse;

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) => _$LeaderboardResponseFromJson(json);
}

extension LeaderboardResponseX on LeaderboardResponse {
  MappedLeaderboardData toDomain() {
    final currentUser = currentUserPosition.toDomain();

    final usersList = data.map((user) => user.toDomain()).toList();

    final currentUserInList = usersList.firstWhereOrNull((element) => element.rank == currentUser.rank) ?? currentUser;

    return (
      currentUser: currentUserInList.copyWith(username: t.leaderboard.currentUserLabel),
      usersList: usersList,
      totalPages: meta.pagination.total,
    );
  }
}
