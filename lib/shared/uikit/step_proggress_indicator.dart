import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    super.key,
    this.spacing = 6.0,
  });

  final int currentStep;
  final int totalSteps;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dotWidth = _calculateDotWidth(constraints.maxWidth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSmoothIndicator(
              activeIndex: currentStep,
              count: totalSteps,
              effect: WormEffect(
                dotHeight: 6,
                radius: 20,
                dotWidth: dotWidth,
                spacing: spacing,

                activeDotColor: context.appTheme.orange500,
                dotColor: context.appTheme.beige800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                t.common.step_count(active: currentStep + 1, total: totalSteps),

                style: subheadH5Medium.copyWith(color: context.appTheme.beige400),
              ),
            ),
          ],
        );
      },
    );
  }

  double _calculateDotWidth(double maxWidth) {
    if (totalSteps <= 0) return 0;

    final totalSpacing = spacing * (totalSteps - 1);
    final width = (maxWidth - totalSpacing) / totalSteps;

    return width > 0 ? width : 0;
  }
}
