import 'package:flutter/material.dart';
import 'package:reforge/shared/pickers/universal_number_piker.dart';

class IntegerScrollPicker extends StatelessWidget {
  const IntegerScrollPicker({
    required this.initialValue,
    required this.onChanged,
    this.unitSuffix,
    this.start = 0,
    this.end = 300,
    this.step = 5,
    super.key,
  });

  final int start;
  final int end;
  final int step;
  final int initialValue;
  final ValueChanged<int> onChanged;
  final String? unitSuffix;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      (end - start) ~/ step + 1,
      (index) => start + (index * step),
    );

    return UniversalNumberPicker<int>(
      items: items,
      initialValue: initialValue,
      onChanged: onChanged,
      valueFormatter: (val) => unitSuffix != null ? '$val $unitSuffix' : '$val',
    );
  }
}
