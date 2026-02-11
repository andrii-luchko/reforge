import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

class MultiOptionSwitcher<T> extends StatelessWidget {
  const MultiOptionSwitcher({
    required this.selectedValue,
    required this.values,
    required this.labelBuilder,
    required this.onSelected,
    this.height = 56.0,
    this.padding = const EdgeInsets.all(2),
    this.borderRadius,
    this.itemTextStyle,
    super.key,
  }) : assert(values.length >= 2, 'At least 2 values must be passed');

  final T? selectedValue;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;

  final double height;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final TextStyle? itemTextStyle;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final selectedIndex = values.indexOf(selectedValue as T);

    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    final effectiveTextStyle = itemTextStyle ?? subheadH3Medium.copyWith(color: appTheme.beige100);

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: appTheme.beige900,
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: appTheme.strokeCard),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final itemWidth = availableWidth / values.length;

          return Stack(
            children: [
              if (selectedIndex != -1)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,

                  left: selectedIndex * itemWidth,
                  width: itemWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: appTheme.orange500,
                      borderRadius: BorderRadius.circular(
                        (effectiveBorderRadius.topLeft.x - padding.horizontal / 2).clamp(0, 100),
                      ),
                    ),
                  ),
                ),

              Row(
                children: values.map((value) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (selectedValue != value) {
                          onSelected(value);
                          unawaited(HapticFeedback.lightImpact());
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: effectiveTextStyle,
                          child: Text(
                            labelBuilder(value),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
