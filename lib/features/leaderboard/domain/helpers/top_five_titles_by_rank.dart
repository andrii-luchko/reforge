String topFiveTitlesByRank(int rank) {
  return const {
        1: 'Daizōshō',
        2: 'Might',
        3: 'Judgement',
        4: 'Strife',
        5: 'Burden',
      }[rank] ??
      'Soldier';
}
