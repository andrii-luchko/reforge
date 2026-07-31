import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/badge_image.dart';
import 'package:reforge/shared/dialogs/default_dialog_header.dart';
import 'package:reforge/shared/uikit/app_tag.dart';

class BadgeDetailsBottomSheet extends StatelessWidget {
  const BadgeDetailsBottomSheet._({required this.badge});

  final BadgeEntity badge;

  static Future<void> show(
    BuildContext context, {
    required BadgeEntity badge,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      builder: (_) => BadgeDetailsBottomSheet._(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final requirementTitle = badge.requirementTitle?.trim();
    final description = badge.description?.trim();
    final hasRequirement = requirementTitle?.isNotEmpty ?? false;
    final hasDescription = description?.isNotEmpty ?? false;

    final tierTag = badge.isLocked
        ? AppTag(
            text: t.achievements.badgeDetails.lockedPreview,
          )
        : AppTag(
            text: t.achievements.badgeDetails.currentTier(
              tier: badge.tier ?? 1,
            ),
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.beige900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: theme.strokeCard)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DefaultDialogHeader(title: badge.title),
              const SizedBox(height: 24),
              Center(
                child: SizedBox.square(
                  dimension: 184,
                  child: badge.imageUrl.isNotEmpty
                      ? BadgeImage.network(url: badge.imageUrl)
                      : BadgeImage.asset(asset: Assets.images.png.lock.path),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: FittedBox(child: tierTag)),

              if (hasRequirement) ...[
                const SizedBox(height: 24),
                Text(
                  requirementTitle!,
                  textAlign: TextAlign.center,
                  style: subheadH2Medium.copyWith(color: theme.orange500),
                ),
              ],
              if (hasDescription) ...[
                const SizedBox(height: 12),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: bodyLRegular.copyWith(
                    color: theme.beige100,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
