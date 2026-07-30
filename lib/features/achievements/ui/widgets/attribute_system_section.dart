import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reforge/app/di/service_injector.dart' as di;
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/ui/guide/achievements_page_guide_scope.dart';
import 'package:reforge/features/achievements/ui/widgets/attributes_guide_bottom_sheet.dart';
import 'package:reforge/features/achievements/ui/widgets/attributes_list.dart';
import 'package:reforge/features/guides/controller/guide_cubit.dart';
import 'package:reforge/features/guides/ui/guides/forge_attributes_guide.dart';
import 'package:reforge/features/guides/ui/widgets/guide_target.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class AttributeSystemSection extends StatelessWidget {
  const AttributeSystemSection({
    required this.attributes,
    this.guide,
    this.guideCubit,
    super.key,
  });

  final List<AttributesEntity> attributes;
  final ForgeAttributesGuide? guide;
  final GuideCubit? guideCubit;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final guide = this.guide;
    final guideCubit = this.guideCubit;

    final widget = DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: appTheme.beige900),
      child: Container(
        padding: const .all(16),
        decoration: BoxDecoration(
          border: Border.all(color: appTheme.strokeCard),
          gradient: appTheme.cardNavigation,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: .start,
          spacing: 16,
          children: [
            const AttributeSystemHeader(),
            if (attributes.isEmpty)
              EmptyListMessage(
                icon: Icons.visibility_off_outlined,
                iconSize: 48,
                title: t.achievements.noAttributesFound,
                subtitle: t.achievements.noAttributesSubtitle,
              )
            else
              AttributesList(
                attributes: attributes,
                guide: guide,
                guideCubit: guideCubit,
              ),
          ],
        ),
      ),
    );

    return guide != null && guideCubit != null
        ? GuideTarget(
            enableAutoScroll: true,
            anchor: guide.anchor(ForgeAttributesGuideStep.intro),
            scope: achievementsPageGuideScope,
            guideCubit: guideCubit,
            tooltip: guide.tooltip(ForgeAttributesGuideStep.intro),
            child: widget,
          )
        : widget;
  }
}

class AttributeSystemHeader extends StatelessWidget {
  const AttributeSystemHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              Text(
                t.achievements.attributeSystem,
                style: subheadH2Medium.copyWith(color: appTheme.beige100),
              ),
              Text(
                t.achievements.xpDistribution,
                style: bodyMRegular.copyWith(color: appTheme.beige700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        AppIconButton.icon(
          iconData: Icons.info_outline_rounded,
          onPressed: () {
            unawaited(di.getIt<AnalyticsService>().logEvent(AnalyticsEvents.achievementsAttributeGuideClick));
            unawaited(ForgeSystemGuideSheet.showForgeSystemGuide(context));
          },
        ),
      ],
    );
  }
}
