import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/exercise_results/result_exercise_data.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/exercise_results/result_exercise_header.dart';
import 'package:reforge/features/exercise_session/ui/active_exercise/widgets/previous_result_dialog.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/ui/widgets/workout_list_tile.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class WorkoutInfoTile extends StatefulWidget {
  const WorkoutInfoTile({
    required this.result,
    required this.system,
    super.key,
  });

  final PreviousExerciseResult result;
  final MeasurementSystem system;
  @override
  State<WorkoutInfoTile> createState() => _WorkoutInfoTileState();
}

class _WorkoutInfoTileState extends State<WorkoutInfoTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        unawaited(_controller.forward());
      } else {
        unawaited(_controller.reverse());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final appTheme = context.appTheme;

    final wsets = result.sets
        .mapIndexed(
          (i, set) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ResultExerciseData(
              metrics: result.metrics,
              set: set,
              system: widget.system,
              setNumber: i + 1,
            ),
          ),
        )
        .toList();

    final hasMetricsAndSets = result.metrics.isNotEmpty && result.sets.isNotEmpty;
    final hasNotes = result.notes != null && result.notes!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StaticWorkoutTile(
          onTap: _handleTap,
          title: result.name,
          description: result.description,
          imageUrl: result.imageUrl,
          icon: RotationTransition(
            turns: _iconTurns,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: appTheme.beige200,
              size: 32,
            ),
          ),
        ),

        SizeTransition(
          sizeFactor: _controller,
          alignment: Alignment.topLeft,
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              children: [
                if (hasMetricsAndSets) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ResultExerciseHeader(
                      metrics: result.metrics,
                      system: widget.system,
                    ),
                  ),

                  ...wsets,
                ] else ...[
                  const _EmptyInfoSection(),
                ],

                if (hasNotes)
                  NotesSection(
                    notes: result.notes,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyInfoSection extends StatelessWidget {
  const _EmptyInfoSection();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Center(
        child: Column(
          spacing: 8,
          children: [
            Icon(Icons.info_outline_rounded, color: appTheme.beige600, size: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                t.training_details.empty_sets_title,
                style: bodyLRegular.copyWith(color: appTheme.beige600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
