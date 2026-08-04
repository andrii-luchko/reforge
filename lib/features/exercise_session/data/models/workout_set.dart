import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

part 'workout_set.freezed.dart';

@freezed
sealed class WorkoutSet with _$WorkoutSet {
  const WorkoutSet._();

  factory WorkoutSet({
    required int id,
    String? clientSetId,
    int? setNumber,
    Duration? time,
    double? distance,
    double? pace,
    double? weight,
    int? reps,
    double? degrees,
    int? selectedTier,
    int? programSegmentId,
    @Default(false) bool isDone,
    @Default(false) bool isBusy,
  }) = _WorkoutSet;

  bool get isEmpty =>
      time == null && distance == null && pace == null && weight == null && reps == null && degrees == null;

  WorkoutSet toImperial() {
    return copyWith(
      distance: distance != null ? MeasureSystemValues.toMiles(distance!) : null,
      pace: pace != null ? MeasureSystemValues.toMiles(pace!) : null,
      weight: weight != null ? MeasureSystemValues.toPounds(weight!) : null,
    );
  }

  WorkoutSet toMetric() {
    return copyWith(
      distance: distance != null ? MeasureSystemValues.toKm(distance!) : null,
      pace: pace != null ? MeasureSystemValues.toKm(pace!) : null,
      weight: weight != null ? MeasureSystemValues.toKg(weight!) : null,
    );
  }

  WorkoutSet copyWithMetric(WorkoutMetric metric, dynamic value) {
    return switch (metric) {
      WorkoutMetric.time => copyWith(time: value as Duration?),
      WorkoutMetric.distance => copyWith(distance: value as double?),
      WorkoutMetric.pace => copyWith(pace: value as double?),
      WorkoutMetric.weight => copyWith(weight: value as double?),
      WorkoutMetric.reps => copyWith(reps: (value as num?)?.toInt()),
      WorkoutMetric.degrees => copyWith(degrees: value as double?),
    };
  }

  dynamic getValue(WorkoutMetric metric) {
    return switch (metric) {
      WorkoutMetric.time => time,
      WorkoutMetric.distance => distance,
      WorkoutMetric.pace => pace,
      WorkoutMetric.weight => weight,
      WorkoutMetric.reps => reps,
      WorkoutMetric.degrees => degrees,
    };
  }

  String formatValue({required WorkoutMetric metric, MeasurementSystem system = MeasurementSystem.metric}) {
    switch (metric) {
      case WorkoutMetric.time:
        if (time == null) return '-';
        return _formatDuration(time!);

      case WorkoutMetric.distance:
        return _formatDouble(distance);
      case WorkoutMetric.weight:
        return _formatDouble(weight);
      case WorkoutMetric.pace:
        return _formatDouble(pace);

      case WorkoutMetric.reps:
        if (reps == null) return '-';
        return reps.toString();

      case WorkoutMetric.degrees:
        return _formatDouble(degrees, suffix: '°');
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    return hours > 0 ? '${hours.toString().padLeft(2, '0')}:$minutes:$seconds' : '$minutes:$seconds';
  }

  String _formatDouble(double? val, {String suffix = ''}) {
    if (val == null) return '-';

    final formatted = (val % 1 == 0) ? val.toInt().toString() : val.toStringAsFixed(2);

    return '$formatted$suffix';
  }
}

extension WorkoutSetValidation on WorkoutSet {
  bool isValid(List<WorkoutMetric> metrics) {
    if (metrics.contains(WorkoutMetric.reps)) {
      if (reps == null || reps! <= 0) return false;
    }

    if (metrics.contains(WorkoutMetric.weight)) {
      if (weight == null || weight! < 0) return false;
    }

    if (metrics.contains(WorkoutMetric.distance)) {
      if (distance == null || distance! <= 0) return false;
    }

    if (metrics.contains(WorkoutMetric.time)) {
      if (time == null || time!.inSeconds <= 0) return false;
    }

    if (metrics.contains(WorkoutMetric.pace)) {
      if (pace == null || pace! <= 0) return false;
    }

    if (metrics.contains(WorkoutMetric.degrees)) {
      if (degrees == null) return false;
    }

    return true;
  }
}
