import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/workout_instruction/ui/widgets/instruction_section.dart';

class LoreStep extends StatelessWidget {
  const LoreStep({
    required this.isLast,
    required this.stepText,
    super.key,
  });
  final bool isLast;
  final String stepText;

  @override
  Widget build(BuildContext context) {
    final activeColor = context.appTheme.orange500;
    final inactiveColor = context.appTheme.beige800;
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: CustomPaint(
              painter: TimelinePainter(
                isLast: isLast,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                stepText,
                style: subheadH6Regular.copyWith(
                  color: context.appTheme.beige700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
