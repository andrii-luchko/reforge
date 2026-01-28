import 'package:flutter/material.dart';
import 'package:reforge/shared/pickers/universal_number_piker.dart';

class DecimalScrollPicker extends StatelessWidget {
  const DecimalScrollPicker({
    required this.initialValue,
    required this.onChanged,
    this.unitSuffix,
    this.start = 1.0,
    this.end = 15.0,
    this.step = 0.1,
    super.key,
  });

  final double start;
  final double end;
  final double step;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String? unitSuffix;

  @override
  Widget build(BuildContext context) {
    final count = ((end - start) / step).floor() + 1;

    final items = List.generate(count, (index) {
      final value = start + (index * step);
      return double.parse(value.toStringAsFixed(2));
    });

    return UniversalNumberPicker<double>(
      items: items,
      initialValue: initialValue,
      onChanged: onChanged,
      valueFormatter: (value) {
        final val = value.toStringAsFixed(step >= 1 ? 0 : 1);
        return unitSuffix != null ? '$val $unitSuffix' : val;
      },
    );
  }
}
