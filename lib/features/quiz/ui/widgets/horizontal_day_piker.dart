import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

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
        spacing: 6,
        runSpacing: 6,
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
        width: 42,
        height: 42,
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
          style: subheadH5Medium.copyWith(
            color: context.appTheme.beige100,
          ),
        ),
      ),
    );
  }
}
