import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_common/models/tier.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_common/ui/widgets/tier/tier_section.dart';
import 'package:reforge/features/workout_common/ui/widgets/uikit/workout_exercise_row.dart';
import 'package:reforge/features/workout_common/ui/widgets/uikit/workout_hearer_row.dart';
import 'package:reforge/features/workout_common/ui/widgets/workout_dialogs.dart';
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
    required this.onTierChanged,
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
  final void Function(int id) onDonePressed;
  final ValueChanged<Tier> onTierChanged;
  final void Function(int id, WorkoutSet set) onUpdateSet;
  final void Function(int id) onRemoveSet;

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
              widget.onTierChanged(value);
            },
          ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: WorkoutHeaderRow(
            metrics: widget.metrics,
            system: widget.system,
          ),
        ),

        _WorkoutSetsList(
          sets: widget.sets,
          metrics: widget.metrics,
          system: widget.system,
          onRemoveSet: widget.onRemoveSet,
          onUpdateSet: widget.onUpdateSet,
          onDonePressed: widget.onDonePressed,
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: ThirtyButton(
            text: 'Add Set',
            onPressed: widget.onAddSet,
          ),
        ),
      ],
    );
  }
}

class _WorkoutSetsList extends StatelessWidget {
  const _WorkoutSetsList({
    required this.sets,
    required this.metrics,
    required this.system,
    required this.onRemoveSet,
    required this.onUpdateSet,
    required this.onDonePressed,
  });

  final List<WorkoutSet> sets;
  final List<WorkoutMetric> metrics;
  final MeasurementSystem system;
  final void Function(int id) onRemoveSet;
  final void Function(int id, WorkoutSet set) onUpdateSet;
  final void Function(int id) onDonePressed;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return _WorkoutSetTile(
          key: ValueKey(set.id),
          index: index,
          set: set,
          metrics: metrics,
          system: system,
          onRemoveSet: onRemoveSet,
          onUpdateSet: onUpdateSet,
          onDonePressed: onDonePressed,
        );
      },
    );
  }
}

class _WorkoutSetTile extends StatelessWidget {
  const _WorkoutSetTile({
    required this.index,
    required this.set,
    required this.metrics,
    required this.system,
    required this.onRemoveSet,
    required this.onUpdateSet,
    required this.onDonePressed,
    super.key,
  });

  final int index;
  final WorkoutSet set;
  final List<WorkoutMetric> metrics;
  final MeasurementSystem system;
  final void Function(int id) onRemoveSet;
  final void Function(int id, WorkoutSet set) onUpdateSet;
  final void Function(int id) onDonePressed;

  @override
  Widget build(BuildContext context) {
    final canDelete = !set.isDone && !set.isBusy;
    final theme = context.appTheme;

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
                      onRemoveSet(set.id);
                      return;
                    }

                    final delete = await WorkoutDialogs.confirmSetDeletion(context);
                    if (delete ?? false) {
                      onRemoveSet(set.id);
                    }
                  }
                : null,
            backgroundColor: theme.beige900,
            foregroundColor: theme.beige100,
            icon: Icons.delete,
            label: t.common.delete_button,
            borderRadius: theme.workoutContainerBorderRadius,
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
              setNumber: index + 1,
              metrics: metrics,
              system: system,
              set: set,
              onMetricChanged: (newSet) => onUpdateSet(set.id, newSet),
              onDonePressed: () => onDonePressed(set.id),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }
}
