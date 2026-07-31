import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/exercise_results/result_exercise_data.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/exercise_results/result_exercise_header.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/ui/widgets/workout_list_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';

class PreviousResultDialog extends StatelessWidget {
  const PreviousResultDialog({required this.result, required this.system, super.key});

  final MeasurementSystem system;

  final PreviousExerciseResult result;

  void onClosePressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final wsets = result.sets.isEmpty
        ? <ResultExerciseData>[]
        : result.sets
              .mapIndexed(
                (i, set) => ResultExerciseData(
                  metrics: result.metrics,
                  set: set,
                  system: system,
                  setNumber: i + 1,
                ),
              )
              .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 32,
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .start,
        children: [
          DefaultDialogHeader(
            title: t.workout.previousAchievements,
            onClosePressed: () => onClosePressed(context),
          ),

          SizedBox(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .start,

                children: [
                  StaticWorkoutTile(
                    title: result.name,
                    description: result.description,
                    imageUrl: result.imageUrl,
                    showTrailingIcon: false,
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ResultExerciseHeader(
                          metrics: result.metrics,
                          system: system,
                        ),
                      ),

                      ...wsets,
                    ],
                  ),
                  NotesSection(
                    notes: result.notes,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotesSection extends StatelessWidget {
  const NotesSection({this.notes, super.key});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: .start,
      children: [
        Text(
          t.workout.notes,
          style: subheadH5Medium.copyWith(color: context.appTheme.beige100),
        ),

        Container(
          width: double.infinity,
          padding: const .all(16),
          decoration: BoxDecoration(
            borderRadius: .circular(20),
            color: context.appTheme.beige900,
            border: .all(color: context.appTheme.strokeCard),
          ),
          child: Text(notes ?? t.workout.noNotes),
        ),
      ],
    );
  }
}
