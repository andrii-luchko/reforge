import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/training_session/data/models/tier.dart';
import 'package:reforge/features/training_session/data/models/workout_set.dart';
import 'package:reforge/features/training_session/domain/enums/workout_metrics.dart';
import 'package:reforge/features/training_session/ui/widgets/tier/tier_section.dart';
import 'package:reforge/features/training_session/ui/widgets/workout_dialogs.dart';
import 'package:reforge/features/training_session/ui/widgets/uikit/workout_exercise_row.dart';
import 'package:reforge/features/training_session/ui/widgets/uikit/workout_hearer_row.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/buttons/thirty_button.dart';

class DynamicWorkoutForm extends StatefulWidget {
  const DynamicWorkoutForm({
    required this.metrics,
    required this.system,
    required this.sets,

    required this.tiers,
    required this.isTiered,
    required this.selectedTier,
    required this.onTearChanged,
    required this.onAddSet,
    required this.onDonePressed,
    required this.onUpdateSet,
    required this.onRemoveSet,
    super.key,
  });

  final List<WorkoutMetric> metrics;
  final List<Tier> tiers;
  final bool isTiered;
  final Tier? selectedTier;
  final MeasurementSystem system;
  final List<WorkoutSet> sets;

  final VoidCallback onAddSet;
  final void Function(String id) onDonePressed;
  final ValueChanged<Tier> onTearChanged;
  final void Function(String id, WorkoutSet set) onUpdateSet;
  final void Function(String id) onRemoveSet;

  @override
  State<DynamicWorkoutForm> createState() => _DynamicWorkoutFormState();
}

class _DynamicWorkoutFormState extends State<DynamicWorkoutForm> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isTiered)
          TierSection(
            tiers: widget.tiers,
            controller: _controller,
            initialTier: widget.selectedTier,
            onTearChanged: (value) {
              _controller.text = value.title;
              widget.onTearChanged(value);
            },
          ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: WorkoutHeaderRow(
            metrics: widget.metrics,
            system: widget.system,
          ),
        ),

        ...buildSetList(context),

        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: ThirtyButton(
            text: "Add Set",
            onPressed: widget.onAddSet,
          ),
        ),
      ],
    );
  }

  List<Widget> buildSetList(BuildContext context) {
    return widget.sets.asMap().entries.map((entry) {
      final index = entry.key;
      final set = entry.value;

      final canDelete = !set.isDone && !set.isBusy;

      return Slidable(
        enabled: canDelete,
        key: ValueKey(set.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: canDelete
                  ? (context) async {
                      if (set.isEmpty) {
                        widget.onRemoveSet(set.id);
                        return;
                      }

                      final delete = await WorkoutDialogs.confirmSetDeletion(context);
                      if (delete ?? false) {
                        widget.onRemoveSet(set.id);
                      }
                    }
                  : null,
              backgroundColor: context.appTheme.beige900,
              foregroundColor: context.appTheme.beige100,
              icon: Icons.delete,
              label: t.common.delete_button,
              borderRadius: context.appTheme.workoutContainerBorderRadius,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsGeometry.only(bottom: 16),
          child: AbsorbPointer(
            absorbing: set.isBusy,
            child: AnimatedOpacity(
              duration: Durations.medium1,
              opacity: set.isBusy ? 0.5 : 1.0,
              child: WorkoutExerciseRow(
                key: ValueKey(set.id),
                setNumber: index + 1,
                metrics: widget.metrics,
                system: widget.system,
                set: set,
                onMetricChanged: (newSet) => widget.onUpdateSet(set.id, newSet),
                onDonePressed: () => widget.onDonePressed(set.id),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
            ),
          ),
        ),
      );
    }).toList();
  }
}
