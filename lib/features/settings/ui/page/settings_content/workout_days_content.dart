import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/validation/generic_validation_cubit.dart';
import 'package:reforge/core/validation/widgets/generic_save_listener.dart';
import 'package:reforge/features/quiz/ui/widgets/horizontal_day_piker.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';
import 'package:reforge/features/settings/domain/enum/workout_settings.dart';
import 'package:reforge/features/settings/ui/page/base_edit_page.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/animations/error_shake_widget.dart';
import 'package:reforge/shared/uikit/buttons/secondary_button.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

typedef WorkoutFrequencyValue = ({int? daysPerWeek, List<WeekDay> specificDays});

class WorkoutDaysPage extends StatelessWidget {
  const WorkoutDaysPage({
    required this.specificWeekDays,
    required this.workoutsPerWeek,

    super.key,
  });

  final int? workoutsPerWeek;
  final List<WeekDay> specificWeekDays;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.read<UserCubit>();
    return BlocProvider(
      create: (context) => GenericValidationCubit<WorkoutFrequencyValue>(
        initialValue: (
          daysPerWeek: workoutsPerWeek,
          specificDays: specificWeekDays,
        ),
        validator: workoutFrequencyValidator,
        onSave: (value) => onSave(value, userCubit),
      ),
      child: GenericSaveListener<WorkoutFrequencyValue>(
        child: BaseSettingsEditPage(
          title: WorkoutSettings.workoutDays.title(t),
          body: const WorkoutDaysContent(),
        ),
      ),
    );
  }

  Future<void> onSave(WorkoutFrequencyValue value, UserCubit cubit) async {
    final result = await cubit.updateProfile(
      PatchProfileRequest(
        workoutDaysPerWeek: value.daysPerWeek,
        specificWorkoutDays: value.specificDays.toIntList(),
      ),
    );
    if (result case ErrorR(error: final e)) {
      throw e;
    }
  }
}

class WorkoutDaysContent extends StatelessWidget {
  const WorkoutDaysContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericValidationCubit<WorkoutFrequencyValue>, GenericValidationState<WorkoutFrequencyValue>>(
      builder: (context, state) {
        final cubit = context.read<GenericValidationCubit<WorkoutFrequencyValue>>();
        final error = state is GenericValidationError ? state.error : null;
        return Column(
          mainAxisAlignment: .spaceBetween,
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                WorkoutFrequencyPicker(
                  daysPerWeek: state.value.daysPerWeek,
                  specificDays: state.value.specificDays,
                  onDaysPerWeekChanged: (count) {
                    cubit.onChanged((daysPerWeek: count, specificDays: state.value.specificDays));
                  },
                  onSpecificDaysChanged: (days) {
                    cubit.onChanged((daysPerWeek: state.value.daysPerWeek, specificDays: days));
                  },
                ),
                const SizedBox(height: 8),
                ErrorShakeWidget(
                  shake: state is GenericValidationError,
                  error: error,
                ),
              ],
            ),

            SecondaryButton(
              text: t.common.save_changes_button,
              onPressed: cubit.save,
            ),
          ],
        );
      },
    );
  }
}

String? workoutFrequencyValidator(WorkoutFrequencyValue value) {
  final count = value.daysPerWeek;
  final selectedDays = value.specificDays;

  if (count == null) {
    return t.validation.select_days_count;
  }

  if (selectedDays.isEmpty) {
    return t.validation.select_at_least_one_day;
  }

  if (selectedDays.length < count) {
    return t.validation.not_enough_days_selected(
      selected: selectedDays.length,
      max: count,
    );
  }
  if (selectedDays.length > count) {
    return t.validation.too_many_days_selected(
      selected: selectedDays.length,
      max: count,
    );
  }

  return null;
}

class WorkoutFrequencyPicker extends StatefulWidget {
  const WorkoutFrequencyPicker({
    required this.daysPerWeek,
    required this.specificDays,
    required this.onDaysPerWeekChanged,
    required this.onSpecificDaysChanged,
    super.key,
  });

  final int? daysPerWeek;
  final List<WeekDay> specificDays;
  final ValueChanged<int> onDaysPerWeekChanged;
  final ValueChanged<List<WeekDay>> onSpecificDaysChanged;

  @override
  State<WorkoutFrequencyPicker> createState() => _WorkoutFrequencyPickerState();
}

class _WorkoutFrequencyPickerState extends State<WorkoutFrequencyPicker> {
  final _numberCountController = TextEditingController();
  final _specificDaysController = TextEditingController();

  final _numberCountPortalController = PortalSelectController();
  final _specificDaysPortalController = PortalSelectController();

  @override
  void initState() {
    super.initState();
    if (widget.daysPerWeek != null) {
      _numberCountController.text = widget.daysPerWeek.toString();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _updateSpecificDaysText(widget.specificDays);
  }

  @override
  void didUpdateWidget(WorkoutFrequencyPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.daysPerWeek != widget.daysPerWeek) {
      _numberCountController.text = widget.daysPerWeek?.toString() ?? '';
    }
    if (oldWidget.specificDays != widget.specificDays) {
      _updateSpecificDaysText(widget.specificDays);
    }
  }

  void _updateSpecificDaysText(List<WeekDay> value) {
    final copy = List<WeekDay>.from(value)..sort((a, b) => a.value.compareTo(b.value));
    final text = copy.map<String>((day) => day.label(context)).join(', ');

    if (_specificDaysController.text != text) {
      _specificDaysController.text = text;
    }
  }

  @override
  void dispose() {
    _numberCountController.dispose();
    _specificDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberDaysList = List.generate(3, (i) {
      final dayValue = i + 3;
      return Text(
        '$dayValue',
        style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledAppTextField(
          label: t.quiz.steps.workout_frequency.select_days_label,
          field: PortalSelectField(
            key: const ValueKey('numbers'),
            portalController: _numberCountPortalController,
            controller: _numberCountController,
            hintText: t.quiz.steps.workout_frequency.select_days_hint,
            onTap: _specificDaysPortalController.close,
            contentBuilder: (_, _) {
              final initialItem = (widget.daysPerWeek != null && widget.daysPerWeek! >= 3)
                  ? (widget.daysPerWeek! - 3)
                  : 0;

              return ValueScrollPicker(
                initialItem: initialItem,
                onSelectedItemChanged: (index) {
                  final daysCount = index + 3;
                  widget.onDaysPerWeekChanged(daysCount);
                },
                children: numberDaysList,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        LabeledAppTextField(
          key: const ValueKey('specific'),
          label: t.quiz.steps.workout_frequency.select_specific_days_label,
          field: PortalSelectField(
            portalController: _specificDaysPortalController,
            controller: _specificDaysController,
            hintText: t.quiz.steps.workout_frequency.select_specific_days_hint,
            onTap: _numberCountPortalController.close,
            contentBuilder: (context, _) {
              return HorizontalWeekDaysPicker(
                maxSelections: widget.daysPerWeek ?? 0,
                initialValue: widget.specificDays,
                onChanged: widget.onSpecificDaysChanged,
              );
            },
          ),
        ),
      ],
    );
  }
}
