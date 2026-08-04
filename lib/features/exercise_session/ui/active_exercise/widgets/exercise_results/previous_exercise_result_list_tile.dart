import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/exercise_session/ui/widgets/workout_dialogs.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/app_list_tile.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class PreviousExerciseResultListTile extends StatelessWidget {
  const PreviousExerciseResultListTile({required this.result, required this.system, super.key});
  final PreviousExerciseResult result;
  final MeasurementSystem system;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leadingIcon: AppIconButton(
        iconAsset: Assets.images.icons.dumbbell,
      ),
      title: t.workout.previousAchievementsInline,
      subtitle: t.workout.yourPastHighlights,
      onTap: () async {
        unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.workoutPastResultsClick));
        await WorkoutDialogs.pastResultsDialog(context, result, system);
      },
    );
  }
}
