import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/ui/widgets/attributes_guide_bottom_sheet.dart';
import 'package:reforge/features/achievements/ui/widgets/attributes_list.dart';
import 'package:reforge/shared/empty_list_message.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

class AttributeSystemSection extends StatelessWidget {
  const AttributeSystemSection({required this.attributes, super.key});
  final List<AttributesEntity> attributes;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return DecoratedBox(
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
            attributes.isNotEmpty
                ? EmptyListMessage(
                    icon: Icons.visibility_off_outlined,
                    iconSize: 48,
                    title: 'No Attributes Found',
                    subtitle: 'It looks like you have no attributes yet.',
                  )
                : AttributesList(
                    attributes: attributes,
                  ),
          ],
        ),
      ),
    );
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
        Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            Text(
              'Attribute system',
              style: subheadH2Medium.copyWith(color: appTheme.beige100),
            ),
            Text(
              'Your XP distribution',
              style: bodyMRegular.copyWith(color: appTheme.beige700),
            ),
          ],
        ),

        AppIconButton.icon(
          iconData: Icons.info_outline_rounded,
          onPressed: () => ForgeSystemGuideSheet.showForgeSystemGuide(context),
        ),
      ],
    );
  }
}
