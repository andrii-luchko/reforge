enum RunningSetSyncStatus {
  tracking,
  locallyCompleted,
  syncing,
  syncFailed,
  synced;

  static RunningSetSyncStatus fromDatabase(String value) {
    return values.firstWhere(
      (status) => status.name == value,
      orElse: () => RunningSetSyncStatus.syncFailed,
    );
  }
}
