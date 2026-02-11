import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/leaderboard/data/models/immortal_forges_user.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/leaderboard/domain/helpers/top_five_titles_by_rank.dart';

part 'immortal_forges_response.freezed.dart';
part 'immortal_forges_response.g.dart';

@freezed
sealed class ImmortalForgesResponse with _$ImmortalForgesResponse {
  @JsonSerializable(explicitToJson: true)
  const factory ImmortalForgesResponse({
    @Default({}) Map<String, ImmortalForgesUser> data,
  }) = _ImmortalForgesResponse;

  factory ImmortalForgesResponse.fromJson(Map<String, dynamic> json) => _$ImmortalForgesResponseFromJson(json);
}

extension ImmortalForgesMapper on ImmortalForgesResponse {
  List<ImmortalForgeEntity> toDomain() {
    if (data.isEmpty) return [];
    final roles = {
      'artificer': 1,
      'might': 2,
      'judgement': 3,
      'strife': 4,
      'burden': 5,
    };

    // ignore: omit_local_variable_types
    final List<ImmortalForgeEntity> leaders = [];

    roles.forEach((apiKey, rank) {
      final userData = data[apiKey];
      if (userData != null) {
        leaders.add(
          ImmortalForgeEntity(
            userId: userData.userId,
            email: userData.email ?? '',
            avatarUrl: userData.avatarUrl,
            score: userData.score,
            rank: rank,
            title: topFiveTitlesByRank(rank),
          ),
        );
      }
    });

    return leaders;
  }
}
