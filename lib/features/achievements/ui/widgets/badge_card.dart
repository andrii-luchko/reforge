import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/ui/widgets/badge_details_bottom_sheet.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/badge_image.dart';
import 'package:reforge/shared/uikit/buttons/pressable_animation.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({
    required this.badge,
    this.isInteractionEnabled = true,
    super.key,
  });

  final BadgeEntity badge;
  final bool isInteractionEnabled;

  @override
  Widget build(BuildContext context) {
    final image = !badge.isLocked
        ? BadgeImage.network(
            url: badge.imageUrl,
          )
        : BadgeImage.asset(
            asset: Assets.images.png.lock.path,
          );

    return Semantics(
      button: isInteractionEnabled,
      enabled: isInteractionEnabled,
      label: badge.title,
      child: PressableAnimation(
        onTap: isInteractionEnabled
            ? () => unawaited(
                BadgeDetailsBottomSheet.show(context, badge: badge),
              )
            : null,
        child: Column(
          spacing: 5,
          mainAxisSize: .min,
          children: [
            Skeleton.leaf(child: image),
            Text(
              badge.title,
              maxLines: 2,
              overflow: .ellipsis,
              textAlign: .center,
              style: subheadH5Medium.copyWith(
                color: context.appTheme.beige100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
