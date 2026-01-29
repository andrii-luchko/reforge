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
    this.maxOptions = 5,
    this.borderRadius,
    super.key,
  }) : assert(values.length >= 2, 'At least 2 values must be passed'),
       assert(values.length <= maxOptions, 'Too many elements for such a switch');

  final T? selectedValue;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onSelected;
  final int maxOptions;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final selectedIndex = values.indexOf(selectedValue as T);
    final borderRadius = this.borderRadius ?? BorderRadius.circular(50);
    return Container(
      height: 56,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: appTheme.beige900,
        borderRadius: borderRadius,
        border: Border.all(color: appTheme.strokeCard),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth) / values.length;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,

                left: selectedIndex != -1 ? selectedIndex * itemWidth : 0,
                width: itemWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: appTheme.orange500,
                    borderRadius: borderRadius,
                  ),
                ),
              ),

              Row(
                children: values.map((value) {
                  // final isSelected = value == selectedValue;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        onSelected(value);
                        unawaited(HapticFeedback.lightImpact());
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: subheadH5Medium.copyWith(
                            color: appTheme.beige100,
                          ),
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
