import 'package:flutter/material.dart';

class WorkoutRowLayout extends StatelessWidget {
  const WorkoutRowLayout({
    required this.setsCell,
    required this.metricCells,
    required this.doneCell,
    super.key,
  });

  final Widget setsCell;
  final List<Widget> metricCells;
  final Widget doneCell;

  static const double setsWidth = 60;
  static const double doneWidth = 92;
  static const int metricFlex = 2;
  static const double gap = 8;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: gap,

      children: [
        SizedBox(
          width: setsWidth,
          child: setsCell,
        ),

        ...metricCells.map((child) {
          return Expanded(
            flex: metricFlex,
            child: child,
          );
        }),

        SizedBox(
          width: doneWidth,
          child: doneCell,
        ),
      ],
    );
  }
}
