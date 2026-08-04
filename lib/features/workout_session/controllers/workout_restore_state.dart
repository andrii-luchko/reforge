part of 'workout_restore_cubit.dart';

/// Sealed state for the workout session restore flow.
/// Lives independently of [WorkoutSessionFlowCubit] — purely handles detection,
/// user confirmation, and abandonment of interrupted sessions.
@freezed
sealed class WorkoutRestoreState with _$WorkoutRestoreState {
  const WorkoutRestoreState._();

  /// Initial state — no check has been performed yet.
  const factory WorkoutRestoreState.idle() = WorkoutRestoreIdle;

  /// Checking local cache + verifying with the backend.
  const factory WorkoutRestoreState.checking() = WorkoutRestoreChecking;

  /// An interrupted active session was found and is awaiting user confirmation.
  const factory WorkoutRestoreState.pendingRestore({
    required int sessionId,
    required int? programDayId,
    required CachedWorkoutSource source,
    required String? executionPlanJson,
    required int cachedDurationSec,
    required WorkoutSessionDetailsDTO session,
  }) = WorkoutRestorePending;

  /// User confirmed restore — fetching full session details + program day.
  const factory WorkoutRestoreState.restoring() = WorkoutRestoreRestoring;

  /// Restore complete — [WorkoutSessionFlowCubit] has been populated.
  /// Navigate to the restored execution at [resumeExecutionKey].
  const factory WorkoutRestoreState.restored({
    required String resumeExecutionKey,
  }) = WorkoutRestoreRestored;

  /// No interrupted session found, or the user chose to abandon it.
  const factory WorkoutRestoreState.none() = WorkoutRestoreNone;

  /// An error occurred during check or restore.
  const factory WorkoutRestoreState.error(String message) = WorkoutRestoreError;
}
