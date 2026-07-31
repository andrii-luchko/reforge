import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

typedef StepModel = ({
  String number,
  String title,
  String description,
  bool isActive,
});

class InstructionSection extends StatelessWidget {
  const InstructionSection({
    required this.steps,
    this.needDecoration = true,
    super.key,
  });

  final Map<String, String> steps;
  final bool needDecoration;
  @override
  Widget build(BuildContext context) {
    final entriesList = steps.entries.toList();
    final decoration = BoxDecoration(
      color: context.appTheme.beige900,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: context.appTheme.strokeCard,
      ),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: needDecoration ? decoration : null,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            t.workout_instruction.howToPerform,
            style: subheadH2Medium.copyWith(color: context.appTheme.beige100),
          ),
          const SizedBox(height: 8),
          if (entriesList.isEmpty)
            const InstructionEmpty()
          else
            ...List.generate(entriesList.length, (index) {
              final entry = entriesList[index];
              final isLast = index == entriesList.length - 1;

              final numberString = (index + 1).toString().padLeft(2, '0');

              return StepItem(
                step: (
                  number: numberString,
                  title: entry.key,
                  description: entry.value,
                  isActive: index == 0,
                ),
                isLast: isLast,
              );
            }),
        ],
      ),
    );
  }
}

class StepItem extends StatelessWidget {
  const StepItem({
    required this.step,

    required this.isLast,
    super.key,
  });

  final StepModel step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final activeColor = context.appTheme.orange500;
    final inactiveColor = context.appTheme.beige800;
    final textColor = step.isActive ? context.appTheme.beige600 : context.appTheme.beige800;
    final titleColor = step.isActive ? context.appTheme.beige100 : context.appTheme.beige800;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: CustomPaint(
              painter: TimelinePainter(
                isLast: isLast,
                isActive: step.isActive,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: subheadH5Medium,
                      children: [
                        TextSpan(
                          text: '${step.number} / ',
                          style: TextStyle(
                            color: step.isActive ? activeColor : inactiveColor,
                          ),
                        ),
                        TextSpan(
                          text: step.title,
                          style: TextStyle(color: titleColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    step.description,
                    style: subheadH6Regular.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  TimelinePainter({
    required this.isLast,
    required this.activeColor,
    required this.inactiveColor,
    this.isActive = true,
    this.dotRadius = 4.0,
  });

  final bool isLast;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final glowRadius = dotRadius * 2.5;

    final dotCenter = Offset(size.width / 2, 10);

    final Gradient gradient = RadialGradient(
      colors: [
        (isActive ? activeColor : inactiveColor).withValues(alpha: .7),
        (isActive ? activeColor : inactiveColor).withValues(alpha: 0),
      ],
    );

    final glowPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: dotCenter, radius: glowRadius),
      )
      ..blendMode = BlendMode.srcOver;

    canvas.drawCircle(dotCenter, glowRadius, glowPaint);
    final mainDotPaint = Paint()
      ..color = isActive ? activeColor : inactiveColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotCenter, isActive ? dotRadius + 0.5 : dotRadius, mainDotPaint);

    if (isLast) return;

    final linePaint = Paint()
      ..color = isActive ? activeColor.withValues(alpha: 0.9) : inactiveColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var startY = dotCenter.dy + dotRadius + 6;
    final endY = size.height;

    const dashHeight = 3;
    const dashSpace = 5;

    while (startY < endY) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        linePaint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.isLast != isLast;
  }
}

class InstructionEmpty extends StatelessWidget {
  const InstructionEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: context.appTheme.orange500,
            ),
            const SizedBox(height: 16),
            Text(
              t.workout_instruction.instructionsPlaceholder,
              textAlign: TextAlign.center,
              style: subheadH6Regular.copyWith(
                color: context.appTheme.beige600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
