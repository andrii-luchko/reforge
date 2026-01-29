import 'package:flutter/material.dart';

import 'package:reforge/app/constants/workout_constants.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/active_workout/ui/widgets/previous_result_dialog.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/rest_timer/ui/widgets/rest_timer/rest_timer_dialog.dart';
import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/app_dialog.dart';
import 'package:reforge/shared/dialogs/edit_dialog_template.dart';
import 'package:reforge/shared/dialogs/two_options_dialog_template.dart';
import 'package:reforge/shared/pickers/app_time_piker.dart';
import 'package:reforge/shared/pickers/decimal_scroll_piker.dart';
import 'package:reforge/shared/pickers/distance_scroll_piker.dart';
import 'package:reforge/shared/pickers/integer_scroll_piker.dart';

class WorkoutDialogs {
  const WorkoutDialogs._();

  static Future<void> pastResultsDialog(
    BuildContext context,
    PreviousExerciseResult result,
    MeasurementSystem system,
  ) {
    return AppDialog.show<void>(
      context,
      child: PreviousResultDialog(
        result: result,
        system: system,
      ),
    );
  }

  static Future<int?> restTimerDialog(
    BuildContext context,
  ) {
    return AppDialog.show<int?>(context, barrierDismissible: false, child: const RestTimerDialog());
  }

  static Future<bool?> confirmWorkoutLeave(
    BuildContext context,
  ) async {
    return AppDialog.show<bool?>(
      context,
      child: TwoOptionsDialog(
        title: 'Finish Workout?',
        rightButtonLabel: t.common.complete_button,
        leftButtonLabel: t.common.cancel_button,
        contentBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Are you sure you want to end this workout? Your progress and XP will be saved only after confirmation.',
            textAlign: TextAlign.center,
            style: bodyLRegular.copyWith(color: context.appTheme.beige600),
          ),
        ),
      ),
    );
  }

  static Future<bool?> confirmSetDeletion(
    BuildContext context,
  ) async {
    return AppDialog.show<bool?>(
      context,
      child: TwoOptionsDialog(
        title: 'Delete Set?',
        rightButtonLabel: t.common.delete_button,
        leftButtonLabel: t.common.cancel_button,
        contentBuilder: (context) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Are you sure you want to delete this set? This action cannot be undone',
            textAlign: TextAlign.center,
            style: bodyLRegular.copyWith(color: context.appTheme.beige600),
          ),
        ),
      ),
    );
  }

  static Future<Duration?> showTimeDialog(BuildContext context, Duration initValue) async {
    return AppDialog.show<Duration?>(
      context,
      child: EditDialogTemplate<Duration>(
        title: t.metrics.time,
        buttonLabel: t.common.confirm_button,
        initialValue: initValue,
        contentBuilder: (context, controller) {
          return AppTimerPicker(
            initialDuration: controller.value,
            onTimerDurationChanged: (newValue) {
              controller.value = newValue;
            },
            hourLabel: t.timer.hours_short,
            minuteLabel: t.timer.minutes_short,
            secondLabel: t.timer.seconds_short,
          );
        },
      ),
    );
  }

  static Future<double?> showDistanceDialog(BuildContext context, double initValue, MeasurementSystem system) async {
    return AppDialog.show<double?>(
      context,
      child: EditDialogTemplate<double>(
        title: system.distanceTitle(t),
        buttonLabel: t.common.submit_button,
        initialValue: initValue,
        contentBuilder: (context, controller) {
          return DistanceScrollPicker(
            initialDistance: controller.value,
            // ignore: avoid_redundant_argument_values
            start: WorkoutConstants.minDistance,
            end: WorkoutConstants.maxDistance(system),
            step: WorkoutConstants.distanceStep,
            system: system,
            onDistanceChanged: (newValue) {
              controller.value = newValue;
            },
          );
        },
      ),
    );
  }

  static Future<double?> showPaceDialog(
    BuildContext context,
    double initValue,
    MeasurementSystem system,
  ) {
    return AppDialog.show<double?>(
      context,
      child: EditDialogTemplate<double>(
        title: t.metrics.pace,
        buttonLabel: t.common.confirm_button,
        initialValue: initValue,
        contentBuilder: (context, controller) {
          return DecimalScrollPicker(
            initialValue: controller.value,
            start: WorkoutConstants.minSpeed,
            end: WorkoutConstants.maxSpeed(system),
            // ignore: avoid_redundant_argument_values
            step: WorkoutConstants.speedStep,
            onChanged: (value) => controller.value = value,
          );
        },
      ),
    );
  }

  static Future<double?> showWeightDialog(BuildContext context, double initValue, MeasurementSystem system) {
    return AppDialog.show<double?>(
      context,
      child: EditDialogTemplate<double>(
        title: system.weightName(t),
        buttonLabel: t.common.confirm_button,
        initialValue: initValue,
        contentBuilder: (context, controller) {
          return DecimalScrollPicker(
            initialValue: controller.value,
            unitSuffix: system.weightSymbol(t),
            start: WorkoutConstants.minWeight,
            end: WorkoutConstants.maxWeight(system),
            step: WorkoutConstants.weightStep(system),
            onChanged: (value) => controller.value = value,
          );
        },
      ),
    );
  }

  static Future<double?> showDegreesDialog(BuildContext context, double initValue) {
    return AppDialog.show<double?>(
      context,
      child: EditDialogTemplate<double>(
        title: t.metrics.degrees,
        buttonLabel: t.common.confirm_button,
        initialValue: initValue,
        contentBuilder: (context, controller) {
          return DecimalScrollPicker(
            initialValue: controller.value,
            unitSuffix: '°',
            start: WorkoutConstants.minDegree,
            end: WorkoutConstants.maxDegree,
            step: WorkoutConstants.degreeStep,
            onChanged: (value) => controller.value = value,
          );
        },
      ),
    );
  }

  static Future<int?> showRepsDialog(BuildContext context, int initValue) {
    return AppDialog.show<int?>(
      context,
      child: EditDialogTemplate<int>(
        title: t.metrics.reps,
        buttonLabel: t.common.confirm_button,
        initialValue: initValue,
        contentBuilder: (context, controller) {
          return IntegerScrollPicker(
            initialValue: controller.value,
            // ignore: avoid_redundant_argument_values
            start: WorkoutConstants.minReps,
            end: WorkoutConstants.maxReps,
            step: WorkoutConstants.repsStep,
            onChanged: (value) => controller.value = value,
          );
        },
      ),
    );
  }

  static Future<dynamic> showAppropriateDialog(
    BuildContext context,
    WorkoutMetric metric,
    dynamic currentValue,
    MeasurementSystem system,
  ) async {
    return switch (metric) {
      WorkoutMetric.time => WorkoutDialogs.showTimeDialog(
        context,
        currentValue as Duration? ?? Duration.zero,
      ),
      WorkoutMetric.distance => WorkoutDialogs.showDistanceDialog(
        context,
        (currentValue as num?)?.toDouble() ?? 0.0,
        system,
      ),
      WorkoutMetric.pace => WorkoutDialogs.showPaceDialog(context, (currentValue as num?)?.toDouble() ?? 0.0, system),

      WorkoutMetric.weight => WorkoutDialogs.showWeightDialog(
        context,
        (currentValue as num?)?.toDouble() ?? 0.0,
        system,
      ),
      WorkoutMetric.reps => WorkoutDialogs.showRepsDialog(
        context,
        (currentValue as num?)?.toInt() ?? 0,
      ),
      WorkoutMetric.degrees => WorkoutDialogs.showDegreesDialog(
        context,
        (currentValue as num?)?.toDouble() ?? 0.0,
      ),
    };
  }
}
