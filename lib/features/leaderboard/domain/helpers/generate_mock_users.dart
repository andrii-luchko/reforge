import 'dart:math';

import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_model.dart';

List<LeaderboardUserModel> generateMockUsers() {
  final random = Random();

  final prefixes = [
    'Shadow',
    'Iron',
    'Void',
    'Mystic',
    'Golden',
    'Dark',
    'Frost',
    'Solar',
    'Lunar',
    'Crimson',
    'Storm',
    'Neon',
    'Cyber',
    'Night',
    'Rogue',
  ];
  final suffixes = [
    'Hunter',
    'Wolf',
    'Dragon',
    'Knight',
    'Blade',
    'Spirit',
    'Walker',
    'Lord',
    'Slayer',
    'Ghost',
    'Reaper',
    'Viper',
    'Titan',
    'Ronin',
    'Master',
  ];

  var currentXp = 250000;

  return List.generate(100, (index) {
    final rank = index + 1;

    final prefix = prefixes[random.nextInt(prefixes.length)];
    final suffix = suffixes[random.nextInt(suffixes.length)];

    final name = '$prefix$suffix${random.nextInt(999)}';

    final drop = random.nextInt(1900) + 100;
    currentXp = (currentXp - drop).clamp(0, 9999999);

    String? avatar;

    if (random.nextDouble() > 0.2) {
      final imgId = random.nextInt(70) + 1;
      avatar = 'https://i.pravatar.cc/150?img=$imgId';
    }

    return LeaderboardUserModel(
      rank: rank,
      username: name,
      avatarUrl: avatar,
      xp: currentXp,
    );
  });
}
