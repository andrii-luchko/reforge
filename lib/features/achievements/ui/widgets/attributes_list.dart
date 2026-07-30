import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/app/utils/formatters/xp_formatter.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/enums/forge_attribute.dart';
import 'package:reforge/features/achievements/ui/guide/achievements_page_guide_scope.dart';
import 'package:reforge/features/guides/ui/guides/forge_attributes_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

class AttributesList extends StatelessWidget {
  const AttributesList({
    required this.attributes,
    super.key,
  });

  final List<AttributesEntity> attributes;

  @override
  Widget build(BuildContext context) {
    final guide = context.read<ForgeAttributesGuide?>();
    final sortedAttributes = [
      for (final attribute in forgeAttributesDisplayOrder)
        ...attributes.where((entity) => entity.attribute == attribute),
    ];
    final targetedAttributes = <ForgeAttribute>{};

    return Column(
      crossAxisAlignment: .start,
      children: [
        for (final entity in sortedAttributes)
          Padding(
            padding: const .only(bottom: 8),
            child: _buildItem(
              entity,
              guide: guide,
              targetedAttributes: targetedAttributes,
            ),
          ),
      ],
    );
  }

  Widget _buildItem(
    AttributesEntity entity, {
    required ForgeAttributesGuide? guide,
    required Set<ForgeAttribute> targetedAttributes,
  }) {
    final item = AttributeChartItem(entity: entity);

    if (guide == null || !targetedAttributes.add(entity.attribute)) {
      return item;
    }

    final step = guide.stepForAttribute(entity.attribute);
    return GuideTarget(
      anchor: guide.attributeAnchor(entity.attribute),
      scope: achievementsPageGuideScope,
      tooltip: guide.tooltip(step),
      child: SizedBox(width: double.infinity, child: item),
    );
  }
}

class AttributeChartItem extends StatelessWidget {
  const AttributeChartItem({
    required this.entity,
    super.key,
  });

  final AttributesEntity entity;

  static const double _maxBarWidth = 200;
  static const double _plateWidth = 3;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final percentage = entity.progress.clamp(0.0, 1.0);

    final targetWidth = (_maxBarWidth * percentage).clamp(_plateWidth, _maxBarWidth);

    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: _plateWidth, end: targetWidth),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, animatedWidth, child) {
            return SizedBox(
              width: animatedWidth,
              height: 32,
              child: CustomPaint(
                painter: ForgeProgressPainter(
                  progress: 1,
                  backgroundColor: const Color(0xFF9D3C10),
                  patternColor: const Color(0xFFB14818),
                  plateColor: const Color(0xFF927769),
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entity.attribute.title(t), style: subheadH3Medium.copyWith(color: appTheme.beige100)),
              const SizedBox(height: 4),
              Text(
                XpFormatter.compact(entity.currentXp),
                style: subheadH8Semibold.copyWith(color: appTheme.beige100),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ForgeProgressPainter extends CustomPainter {
  ForgeProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.patternColor,
    required this.plateColor,
  });

  final double progress;
  final Color backgroundColor;
  final Color patternColor;
  final Color plateColor;

  @override
  void paint(Canvas canvas, Size size) {
    const plateWidth = 3.0;
    final height = size.height;

    final platePaint = Paint()
      ..color = plateColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, plateWidth, height),
      platePaint,
    );

    if (progress <= 0) return;

    final maxProgressWidth = size.width - plateWidth;
    final currentProgressWidth = maxProgressWidth * progress;
    const radius = 4.0;

    final progressPath = Path()
      ..moveTo(plateWidth, 0)
      ..lineTo(plateWidth + currentProgressWidth - radius, 0)
      ..quadraticBezierTo(plateWidth + currentProgressWidth, 0, plateWidth + currentProgressWidth, radius)
      ..lineTo(plateWidth + currentProgressWidth, height - radius)
      ..quadraticBezierTo(plateWidth + currentProgressWidth, height, plateWidth + currentProgressWidth - radius, height)
      ..lineTo(plateWidth, height)
      ..close();

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas
      ..drawPath(progressPath, bgPaint)
      ..save()
      ..clipPath(progressPath);

    final patternPaint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.fill;

    const stripeWidth = 8.0;
    const gap = 12.0;
    final slantOffset = height;

    for (var i = plateWidth - slantOffset; i < plateWidth + currentProgressWidth; i += stripeWidth + gap) {
      final stripePath = Path()
        ..moveTo(i, height)
        ..lineTo(i + slantOffset, 0)
        ..lineTo(i + slantOffset + stripeWidth, 0)
        ..lineTo(i + stripeWidth, height)
        ..close();

      canvas.drawPath(stripePath, patternPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ForgeProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
