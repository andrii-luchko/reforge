enum GuideId {
  leaderboard('leaderboard'),
  factionWars('faction_wars');

  const GuideId(this.storageKey);

  final String storageKey;
}
