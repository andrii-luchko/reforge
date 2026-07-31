import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/ui/guide/achievements_page_guide_scope.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_card.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/ui/guides/forge_attributes_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:showcaseview/showcaseview.dart';

class BadgesPreview extends StatelessWidget {
  const BadgesPreview({
    required this.badges,
    super.key,
  });

  final List<BadgeEntity> badges;

  @override
  Widget build(BuildContext context) {
    final guide = context.read<ForgeAttributesGuide?>();

    if (guide == null) return _buildPreview(interactionEnabled: true);

    final preview = BlocBuilder<GuideCubit, GuideState>(
      buildWhen: (previous, current) {
        return (previous is GuideRunning) != (current is GuideRunning);
      },
      builder: (context, state) {
        return _buildPreview(interactionEnabled: state is! GuideRunning);
      },
    );

    if (badges.isEmpty) return preview;

    return GuideTarget(
      anchor: guide.anchor(ForgeAttributesGuideStep.badges),
      scope: achievementsPageGuideScope,
      tooltip: guide.tooltip(ForgeAttributesGuideStep.badges),
      enableAutoScroll: true,
      scrollAlignment: 0.68,
      tooltipPosition: TooltipPosition.top,
      targetPadding: const EdgeInsets.all(8),
      child: preview,
    );
  }

  Widget _buildPreview({required bool interactionEnabled}) {
    return SizedBox(
      height: 149,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 32) / 3;

          return Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final badge in badges.take(3))
                SizedBox(
                  width: itemWidth,
                  child: BadgeCard(
                    badge: badge,
                    isInteractionEnabled: interactionEnabled,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
