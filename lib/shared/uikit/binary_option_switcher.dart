import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class BinaryOptionSwitcher<T> extends StatelessWidget {
  const BinaryOptionSwitcher({
    required this.selectedValue,
    required this.firstValue,
    required this.secondValue,
    required this.labelBuilder,
    required this.onSelected,
    super.key,
  });

  final T? selectedValue;
  final T firstValue;
  final T secondValue;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

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
            child: _SwitchOption(
              label: labelBuilder(firstValue),
              isSelected: selectedValue == firstValue,
              onTap: () => onSelected(firstValue),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SwitchOption(
              label: labelBuilder(secondValue),
              isSelected: selectedValue == secondValue,
              onTap: () => onSelected(secondValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchOption extends StatelessWidget {
  const _SwitchOption({
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
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
