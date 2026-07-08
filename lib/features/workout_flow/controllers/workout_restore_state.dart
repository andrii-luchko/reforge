part of 'workout_restore_cubit.dart';

/// Sealed state for the workout session restore flow.
/// Lives independently of [WorkoutFlowCubit] — purely handles detection,
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
    required int programDayId,
    required int cachedDurationSec,
    required WorkoutSessionDetailsDTO session,
  }) = WorkoutRestorePending;

  /// User confirmed restore — fetching full session details + program day.
  const factory WorkoutRestoreState.restoring() = WorkoutRestoreRestoring;

  /// Restore complete — [WorkoutFlowCubit] has been populated.
  /// Navigate to the exercise at [resumeExerciseId].
  const factory WorkoutRestoreState.restored({
    required int resumeExerciseId,
  }) = WorkoutRestoreRestored;

  /// No interrupted session found, or the user chose to abandon it.
  const factory WorkoutRestoreState.none() = WorkoutRestoreNone;

  /// An error occurred during check or restore.
  const factory WorkoutRestoreState.error(String message) = WorkoutRestoreError;
}
