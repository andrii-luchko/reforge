import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/uikit/value_scroll_picker.dart';

class UniversalNumberPicker<T extends num> extends StatelessWidget {
  const UniversalNumberPicker({
    required this.items,
    required this.initialValue,
    required this.onChanged,
    this.valueFormatter,
    this.textStyle,
    this.height = 180,
    super.key,
  });

  final List<T> items;
  final T initialValue;
  final ValueChanged<T> onChanged;

  final String Function(T value)? valueFormatter;

  final TextStyle? textStyle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? subheadH1Medium.copyWith(color: context.appTheme.beige100);

    final indexFound = items.indexOf(initialValue);
    final initialIndex = indexFound >= 0 ? indexFound : 0;

    return SizedBox(
      height: height,
      child: ValueScrollPicker(
        initialItem: initialIndex,
        onSelectedItemChanged: (index) {
          onChanged(items[index]);
        },
        children: items.map((value) {
          final text = valueFormatter?.call(value) ?? value.toString();
          return Center(
            child: Text(text, style: style),
          );
        }).toList(),
      ),
    );
  }
}
