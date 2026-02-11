import 'dart:math';

import 'package:collection/collection.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';

List<LeaderboardFactionModel> generateMockFactions() {
  final random = Random(1000);

  var currentXp = 250000;
  var currentUsers = 1000;

  var currentGlobalScore = 100;
  var currentLocalScore = 4;

  return Faction.values.mapIndexed((i, e) {
    final drop = random.nextInt(1900) + 100;
    currentXp = (currentXp - drop).clamp(0, 9999999);

    final userDrop = random.nextInt(100) + 10;
    currentUsers = (currentUsers - userDrop).clamp(0, 9999999);

    final globalDrop = random.nextInt(10) + 10;
    currentGlobalScore = (currentGlobalScore - globalDrop).clamp(0, 9999999);

    const localDrop = 1;
    currentLocalScore = (currentGlobalScore - localDrop).clamp(0, 9999999);

    return LeaderboardFactionModel(
      faction: e,
      xp: currentXp,
      activeUsers: currentUsers,
      globalScore: currentGlobalScore,
      localScore: currentLocalScore,
    );
  }).toList();
}
