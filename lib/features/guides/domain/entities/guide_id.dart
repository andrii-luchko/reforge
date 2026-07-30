enum GuideId {
  leaderboard('leaderboard'),
  factionWars('faction_wars'),
  plateOfKeragura('plate_of_keragura');

  const GuideId(this.storageKey);

  final String storageKey;
}
