import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/theme/app_theme.dart';

import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/uikit/fields/labeled_text_filed.dart';
import 'package:reforge/shared/uikit/fields/portal_select_picker.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class WorkoutFrequencyStep extends StatefulWidget {
  const WorkoutFrequencyStep({super.key});

  @override
  State<WorkoutFrequencyStep> createState() => _WorkoutFrequencyStepState();
}

class _WorkoutFrequencyStepState extends State<WorkoutFrequencyStep> {
  late final List<Text> _numberDaysList = List.generate(
    7,
    (i) => Text(
      '${i + 1}',
      style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
    ),
  );

  final _numberCountController = TextEditingController();
  final _numberCountPortalController = PortalSelectController();
  final _specificDaysController = TextEditingController();
  List<WeekDay> _selectedDays = [];
  final _specificDaysPortalController = PortalSelectController();
  final _scrollController = FixedExtentScrollController();

  @override
  void dispose() {
    _numberCountController.dispose();
    _specificDaysController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quiz.steps.workout_frequency.title,
          style: subheadH1Medium.copyWith(color: context.appTheme.beige100),
        ),
        const SizedBox(height: 32),
        LabeledAppTextField(
          label: t.quiz.steps.workout_frequency.select_days_label,
          field: PortalSelectField(
            key: const ValueKey('numbers'),

            controller: _numberCountController,
            hintText: t.quiz.steps.workout_frequency.select_days_hint,
            onTap: _specificDaysPortalController.close,
            contentBuilder: (_, _) {
              return ValueScrollPicker(
                scrollController: _scrollController,
                onSelectedItemChanged: (i) {
                  _numberCountController.text = (i + 1).toString();
                },
                children: _numberDaysList,
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
                maxSelections: int.tryParse(_numberCountController.text) ?? 0,
                initialValue: _selectedDays,
                onChanged: (value) {
                  setState(() {
                    _selectedDays = value;

                    value.sort((a, b) => a.value.compareTo(b.value));

                    final text = value.map<String>((day) => day.label(context)).join(', ');

                    _specificDaysController.text = text;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class HorizontalWeekDaysPicker extends StatefulWidget {
  const HorizontalWeekDaysPicker({
    required this.initialValue,
    required this.onChanged,
    required this.maxSelections,
    super.key,
  });

  final int maxSelections;
  final List<WeekDay> initialValue;
  final ValueChanged<List<WeekDay>> onChanged;

  @override
  State<HorizontalWeekDaysPicker> createState() => _HorizontalWeekDaysPickerState();
}

class _HorizontalWeekDaysPickerState extends State<HorizontalWeekDaysPicker> {
  late Set<WeekDay> _selectedDays;

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  @override
  void didUpdateWidget(HorizontalWeekDaysPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _parseInitialValue();
    }
  }

  void _parseInitialValue() {
    _selectedDays = widget.initialValue.toSet();
  }

  void _toggleDay(WeekDay day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        if (_selectedDays.length < widget.maxSelections) {
          _selectedDays.add(day);
        } else {
          return;
        }
      }
      _notifyChanges();
    });
  }

  void _notifyChanges() {
    final sortedDays = _selectedDays.toList()..sort((a, b) => a.value.compareTo(b.value));

    widget.onChanged(sortedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: WeekDay.values.map((day) {
          final isSelected = _selectedDays.contains(day);
          final isDisabled = !isSelected && _selectedDays.length >= widget.maxSelections;

          return SelectableChip(
            text: day.label(context),
            isSelected: isSelected,
            isDisabled: isDisabled,
            onPressed: () => _toggleDay(day),
          );
        }).toList(),
      ),
    );
  }
}

class SelectableChip extends StatelessWidget {
  const SelectableChip({
    required this.text,
    required this.isSelected,
    required this.isDisabled,

    required this.onPressed,
    super.key,
  });

  final String text;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        width: 52,
        height: 52,
        padding: const .all(2),
        decoration: BoxDecoration(
          color: isSelected ? context.appTheme.orange500 : context.appTheme.beige900,
          border: isSelected
              ? GradientBoxBorder(
                  gradient: LinearGradient(
                    colors: [
                      context.appTheme.strokeCalendar,
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
              : Border.all(color: context.appTheme.beige800),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: subheadH3Medium.copyWith(
            color: context.appTheme.beige100,
          ),
        ),
      ),
    );
  }
}
