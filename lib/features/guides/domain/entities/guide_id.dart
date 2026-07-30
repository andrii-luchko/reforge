enum GuideId {
  leaderboard('leaderboard'),
  factionWars('faction_wars'),
  plateOfKeragura('plate_of_keragura'),
  forgeAttributes('forge_attributes');

  const GuideId(this.storageKey);

  final String storageKey;
}
