enum RunningMilestoneCandidateStatus {
  pending,
  attempted;

  static RunningMilestoneCandidateStatus fromDatabase(String value) {
    return values.firstWhere(
      (status) => status.name == value,
      orElse: () => RunningMilestoneCandidateStatus.attempted,
    );
  }
}
