import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/quiz/domain/measure_system.dart';

class MeasureSwitcher extends StatelessWidget {
  const MeasureSwitcher({
    required this.selectedMeasure,
    required this.onSelected,
    super.key,
  });

  final MeasurementSystem selectedMeasure;
  final ValueChanged<MeasurementSystem> onSelected;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appTheme.strokeCard),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _MeasureOption(
              label: MeasurementSystem.metric.weight,
              isSelected: selectedMeasure == MeasurementSystem.metric,
              onTap: () => onSelected(MeasurementSystem.metric),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MeasureOption(
              label: MeasurementSystem.imperial.weight,
              isSelected: selectedMeasure == MeasurementSystem.imperial,
              onTap: () => onSelected(MeasurementSystem.imperial),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasureOption extends StatelessWidget {
  const _MeasureOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? appTheme.orange500 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: subheadH3Medium.copyWith(color: appTheme.beige100),
          ),
        ),
      ),
    );
  }
}
