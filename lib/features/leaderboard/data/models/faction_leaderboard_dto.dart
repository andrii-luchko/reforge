import 'package:freezed_annotation/freezed_annotation.dart';

part 'faction_leaderboard_dto.freezed.dart';
part 'faction_leaderboard_dto.g.dart';

@freezed
sealed class FactionLeaderboardDto with _$FactionLeaderboardDto {
  const factory FactionLeaderboardDto({
    required int factionId,
    required String factionName,
    required int totalWins,
    @Default([]) List<int> wonWeeks,
    @Default(0) int totalUsers,
    @Default(0) int totalXp,
    int? periodId,
  }) = _FactionLeaderboardDto;

  factory FactionLeaderboardDto.fromJson(Map<String, dynamic> json) => _$FactionLeaderboardDtoFromJson(json);
}
