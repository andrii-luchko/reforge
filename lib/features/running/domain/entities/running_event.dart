
sealed class RunningEvent {
  const RunningEvent();
}

class LapCompletedEvent extends RunningEvent {
  const LapCompletedEvent({
    required this.segmentIndex,
    this.segmentId,
  });

  final int segmentIndex;
  final int? segmentId;
}

class PlannedWorkoutCompletedEvent extends RunningEvent {
  const PlannedWorkoutCompletedEvent();
}
